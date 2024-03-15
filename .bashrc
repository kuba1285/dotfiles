function cheatsh() { curl "http://cheat.sh/$1"; }
eval "$(starship init $(ps -p $$ -o ucomm=))"
alias less='bat'
alias cat='bat --paging=never'
alias diff='delta -s'
alias ls="eza --icons --git"
alias la="eza -a --icons --git"
alias ll="eza -aahl --icons --git"
alias lt="eza -T -L 3 -a -I 'node_modules|.git|.cache' --icons"
alias lta="eza -T -a -I 'node_modules|.git|.cache' --color=always --icons | less -r"
alias vc='code' # gui code editor
alias clear='paclear -s 5 -c yellow'
export PATH="$PATH:$HOME/bin"

{{ if eq .chezmoi.os "darwin" }}
# Write from Caveats of 'brew (re)install python3'.
# Python3
export PATH="$PATH:/usr/local/bin/python3"
# installed by pip3
export PATH="$PATH:/usr/local/opt/python@3.12/libexec/bin"
{{ end }}

{{ if eq .chezmoi.os "android" }}
export PATH="$PATH:/root/bin"
export PATH="$PATH:/root/go/bin"
export PATH="$PATH:/root/.local/bin"
{{ end }}
