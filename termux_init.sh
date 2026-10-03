#!/data/data/com.termux/files/usr/bin/bash
# =====================================================================
# Even G2「エージェント設定」→ Claude Code 中継サーバー セットアップ（Termux）
#
# 【全体の機序】
#   G2（音声）→ Evenアプリ（エージェント設定）
#     → POST http://<スマホIP>:3700/
#        ・入力したURLにパスを付けずにそのまま送信する
#        ・形式は OpenAI Chat Completions（model="openclaw"）
#        ・ヘッダーは Authorization: Bearer <トークン>
#        ・送られてくるのは今回の発話1件のみ（履歴なし）
#     → server.js（Node.js。本スクリプトで作成）
#     → claude -p "<発話>"（Claude Code 非対話モード。cwd = knowledge-vault）
#     → 回答を Chat Completions 形式の JSON で返却 → G2に表示
#
#   ※ even-terminal（G2ターミナルモード用）はこの経路では使わない
#   ※ アプリのURL欄は http:// まで含めて入力する（例: http://172.18.x.x:3700）
# =====================================================================


# ---------------------------------------------------------------------
# 0. 変数（環境に合わせてここだけ変更する）
# ---------------------------------------------------------------------
G2_TOKEN="123456"                  # Evenアプリの「トークン」と同じ値（推測されにくい長い文字列を推奨）
G2_PORT="3700"                     # 中継サーバーの待受ポート（アプリのURLに付けるポート）
G2_DIR="$HOME/g2-agent"            # server.js の置き場所
GH_USER="kuba1285"                 # GitHubユーザー名（リポジトリ所有者）
VAULT_REPO="knowledge-vault"       # ナレッジベースのリポジトリ名
VAULT_DIR="$HOME/knowledge-vault"  # スマホ側のclone先 = Claudeの作業フォルダ
WORK_BRANCH="claude/g2"            # G2経由の変更を入れる作業ブランチ（mainへは夜間ルーティンでまとめる）
CCA_INSTALLER="$HOME/claude-code-android-install.sh"  # 外部インストーラーの保存名（このスクリプト自身と名前が衝突しないようにする）


# ---------------------------------------------------------------------
# 1. Termux基本環境
# ---------------------------------------------------------------------
# パッケージ一覧の更新と全体アップグレード
yes | pkg update && yes | pkg upgrade

termux-setup-storage   # 端末ストレージ(~/storage)へのアクセス許可ダイアログ
termux-wake-lock       # スリープ中もTermuxのプロセス（中継サーバー）を止めにくくする

# git/gh   : ナレッジベースの取得・commit・push
# nodejs-lts : 中継サーバー(server.js)とClaude Codeの実行環境
yes | pkg install git gh nodejs-lts

touch ~/.hushlogin     # Termux起動時の案内メッセージを非表示


# ---------------------------------------------------------------------
# 2. GitHub接続（ナレッジベースの取得と作業ブランチの準備）
#    対話が必要な処理なので、最も長い外部インストーラーより前に実行する
#    （ここを終えれば、以降は手順7のClaudeログインまで基本的に放置できる）
# ---------------------------------------------------------------------
# 認証：Termuxはブラウザを自動で開けないため、表示されたワンタイムコードを控え、
#       スマホのブラウザで https://github.com/login/device を開いて入力する
#       （ログイン済みなら省略）
gh auth status >/dev/null 2>&1 || gh auth login --hostname github.com --git-protocol https --web

# git push 時に gh の認証情報を使うよう git に設定（これが無いと push でパスワードを求められる）
gh auth setup-git

# commit に必要な作成者情報（未設定だと git commit が失敗する）
git config --global user.name  "$GH_USER"
git config --global user.email "$GH_USER@users.noreply.github.com"

# clone（既に取得済みならスキップ）
if [ ! -d "$VAULT_DIR/.git" ]; then
  gh repo clone "$GH_USER/$VAULT_REPO" "$VAULT_DIR"
fi

# 作業ブランチへ切替：リモートにあればそれを追跡、無ければ作成して初回push
if git -C "$VAULT_DIR" ls-remote --exit-code --heads origin "$WORK_BRANCH" >/dev/null 2>&1; then
  git -C "$VAULT_DIR" switch "$WORK_BRANCH"
else
  git -C "$VAULT_DIR" switch -c "$WORK_BRANCH"
  git -C "$VAULT_DIR" push -u origin "$WORK_BRANCH"
fi


# ---------------------------------------------------------------------
# 3. Claude Code（Android対応版）の導入
#    公式SDK同梱バイナリはandroid-arm64向けが無いため、
#    Android対応の外部インストーラーで claude コマンドを導入する
#    （導入先: /data/data/com.termux/files/usr/bin/claude）
# ---------------------------------------------------------------------
curl -fsSL https://raw.githubusercontent.com/ferrumclaudepilgrim/claude-code-android/main/install.sh -o "$CCA_INSTALLER"
bash "$CCA_INSTALLER"


# ---------------------------------------------------------------------
# 4. Termux / nano の使い勝手設定
# ---------------------------------------------------------------------
# 画面下の補助キー（ESC, CTRL, 矢印など）。反映はTermux再起動後
cat << EOF > "$HOME/.termux/termux.properties"
extra-keys = [ \\
		 ['ESC','|', '/', '~','HOME','UP','END'], \\
		 ['TAB', 'CTRL', '=', '-','LEFT','DOWN','RIGHT'] \\
		]
EOF

# nanoエディタの表示設定
cat << EOF > "$HOME/.nanorc"
set nowrap
set tabsize 4
set softwrap
set titlecolor white,blue 
set numbercolor yellow,black 
set functioncolor white
set statuscolor white,red
EOF


# ---------------------------------------------------------------------
# 5. Termux起動時に中継サーバーを自動起動（バックグラウンド実行＋ログファイル出力）
#    ・.bashrc は上書き（既存の内容は消える。外部インストーラーのPATH追記も消えるため再記述）
#    ・ヒアドキュメントが EOF（引用なし）なので、$G2_TOKEN 等はここで値に展開されて書き込まれる
#      \$ でエスケープした箇所は展開されずに書き込まれ、Termux起動時に評価される
#    ・サーバーはバックグラウンドで動くため、起動後もそのセッションで通常のターミナル操作ができる
#    ・2つ目以降のセッションでは起動済みを検知して二重起動しない
#    ・ログは別セッションで g2log を実行するとリアルタイム表示できる
# ---------------------------------------------------------------------
cat << EOF > "$HOME/.bashrc"
export PATH="\$PATH:\$HOME/.local/bin"   # 外部インストーラーが追記していたPATH（上書きで消えるため明示）
G2_LOG="$G2_DIR/server.log"              # 中継サーバーのログ出力先

# 中継サーバーが未起動のときだけバックグラウンドで起動
#   nohup : セッションを閉じてもサーバーを止めない
#   >>    : ログをファイルに追記（2>&1 でエラー出力も同じファイルへ）
#   &     : バックグラウンド実行 → プロンプトがすぐ戻る
if ! pgrep -f "node $G2_DIR/server.js" >/dev/null; then
  G2_TOKEN=$G2_TOKEN PORT=$G2_PORT G2_CWD=$VAULT_DIR G2_BRANCH=$WORK_BRANCH \\
    nohup node $G2_DIR/server.js >> "\$G2_LOG" 2>&1 &
  echo "G2 bridge started (log: \$G2_LOG)"
fi

# ログ表示：直近30行を表示し、以降は届くたびに追記表示（CTRL+Cで表示だけ終了、サーバーは動き続ける）
alias g2log='tail -n 30 -f "\$G2_LOG"'
# サーバー停止（再起動したいときは g2stop → セッションを開き直す）
alias g2stop='pkill -f "node $G2_DIR/server.js"'
EOF


# ---------------------------------------------------------------------
# 6. 中継サーバー本体（server.js）
#    ヒアドキュメントが 'EOF'（引用あり）なので、中身はシェル展開されずそのまま書き込まれる
#    設定値は .bashrc から環境変数で渡す
# ---------------------------------------------------------------------
mkdir -p "$G2_DIR" && cat > "$G2_DIR/server.js" << 'EOF'
const http = require('http');
const { spawn } = require('child_process');
const os = require('os');
const path = require('path');
const fs = require('fs');

// ===== 設定（.bashrc の環境変数で上書き。未指定時は右側の既定値）=====
const PORT       = Number(process.env.PORT || 3700);
const TOKEN      = process.env.G2_TOKEN || '';                                      // 空なら認証なし
const CWD        = process.env.G2_CWD || path.join(os.homedir(), 'knowledge-vault'); // Claudeの作業フォルダ
const BRANCH     = process.env.G2_BRANCH || 'claude/g2';                            // push先の作業ブランチ
const TIMEOUT_MS = 90000;                                                           // claude応答の待ち上限

// G2の画面向けに回答を短くする指示 + Git運用ルール（Claude Codeの既定システムプロンプトに追記される）
const SYS = 'スマートグラスに表示される。日本語で3文以内、簡潔に答える。'
  + `Gitの作業は ${BRANCH} ブランチで行い、pushは「git push origin ${BRANCH}」の形で実行する。mainには直接commit・pushしない。`;

// -p（非対話）モードでは承認ダイアログを出せないため、許可が必要なツールは自動でブロックされる。
// ここに列挙したものだけを事前許可する（会話で「許可」と言っても許可にはならない）。
const TOOLS = [
  'Read', 'Edit', 'Write', 'Glob', 'Grep',            // ナレッジベースの閲覧・編集
  'WebSearch', 'WebFetch',                            // 天気などのWeb情報取得
  'Bash(git status:*)', 'Bash(git diff:*)', 'Bash(git add:*)',
  'Bash(git commit:*)', 'Bash(git pull:*)', 'Bash(git switch:*)',
  `Bash(git push origin ${BRANCH}:*)`,                // pushは作業ブランチ宛てのみ（mainへのpushはブロック）
];

let hasSession = false;                    // 起動後に1回成功したら以降は --continue で文脈を引き継ぐ
fs.mkdirSync(CWD, { recursive: true });   // 作業フォルダが無い場合は作成（clone前に起動しても落ちないように）

// アプリは履歴を送らず今回の発話1件のみ。念のため最後の user メッセージを取り出す
function lastUserText(body) {
  const msgs = Array.isArray(body.messages) ? body.messages : [];
  for (let i = msgs.length - 1; i >= 0; i--) {
    const m = msgs[i];
    if (m.role !== 'user') continue;
    if (typeof m.content === 'string') return m.content;
    if (Array.isArray(m.content)) return m.content.map(p => p.text || '').join('');
  }
  return '';
}

// claude -p を子プロセスで起動し、標準出力を回答として受け取る
function askClaude(prompt) {
  return new Promise(resolve => {
    const args = ['-p', prompt, '--append-system-prompt', SYS];
    if (hasSession) args.push('--continue');   // 初回は新規セッション（継続先が無いとエラーになるため）
    args.push('--allowedTools', ...TOOLS);     // 可変長引数なので必ず最後に置く
    const child = spawn('claude', args, { cwd: CWD });
    let out = '', err = '';
    const timer = setTimeout(() => { child.kill(); resolve('タイムアウトしました。'); }, TIMEOUT_MS);
    child.stdout.on('data', d => out += d);
    child.stderr.on('data', d => err += d);
    child.on('close', code => {
      clearTimeout(timer);
      if (code === 0) hasSession = true; else console.error('[claude error]', code, err);
      resolve(out.trim() || 'エラー: 応答が空です。');
    });
  });
}

// OpenAI Chat Completions（非ストリーミング）形式のレスポンスを組み立てる
function buildCompletion(answer, model) {
  return {
    id: 'chatcmpl-' + Date.now(),
    object: 'chat.completion',
    created: Math.floor(Date.now() / 1000),
    model: model || 'claude-code',
    choices: [{ index: 0, message: { role: 'assistant', content: answer }, finish_reason: 'stop' }],
  };
}

// トークン照合：送信ヘッダー（Authorization: Bearer <トークン>）またはURLに含まれていれば通す
function isAuthorized(req) {
  if (!TOKEN) return true;
  return JSON.stringify(req.headers).includes(TOKEN) || req.url.includes(TOKEN);
}

http.createServer((req, res) => {
  let raw = '';
  req.on('data', c => raw += c);
  req.on('end', async () => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    console.log('headers:', JSON.stringify(req.headers));
    if (req.method !== 'POST') { res.writeHead(200); return res.end('ok'); }   // 疎通確認用
    if (!isAuthorized(req)) { res.writeHead(401); return res.end('unauthorized'); }

    let body = {};
    try { body = JSON.parse(raw); } catch (e) {}
    const text = lastUserText(body);
    console.log('prompt:', text);
    const answer = text ? await askClaude(text) : '質問を受け取れませんでした。';
    console.log('answer:', answer);

    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(buildCompletion(answer, body.model)));
  });
}).listen(PORT, '127.0.0.1', () => console.log(`G2 bridge listening on :${PORT} (cwd=${CWD}, branch=${BRANCH})`));
EOF


# ---------------------------------------------------------------------
# 7. Claude Code 初回ログイン
#    ログイン完了後 /exit で終了 → Termuxを開き直すと .bashrc により中継サーバーが起動する
# ---------------------------------------------------------------------
claude
