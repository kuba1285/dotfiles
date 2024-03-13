#!/bin/bash

grep -q "TMOUT=900" ~/.bashrc ||
cat << EOF >> ~/.bashrc
export PATH="\$PATH:$HOME/bin"

pokefetch
TMOUT=900
TRAPALRM() {
MODELS=(\$(ls -d $HOME/bin/models/*))
SEC=\`date +%S\`
I=\$((SEC%\$(echo \${#MODELS[@]})+1))
3d-ascii-viewer -z 120 \${MODELS[\$I]}
}
EOF

# yabai sudoers setting
echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d " " -f 1) $(which yabai) --load-sa" | sudo tee /private/etc/sudoers.d/yabai
