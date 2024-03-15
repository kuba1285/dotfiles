#!/bin/bash

cat << EOF >> ~/.zshrc
export PATH="\$PATH:$HOME/bin"
neowofetch --gap -30 --ascii \$(fortune -s | pokemonsay -w 30)"

neofetch
TMOUT=900
TRAPALRM() {
MODELS=(\$(ls -d $HOME/bin/models/*))
SEC=\`date +%S\`
I=\$((SEC%\$(echo \${#MODELS[@]})+1))
3d-ascii-viewer -z 120 \${MODELS[\$I]}
}
EOF

{{ if eq .chezmoi.os "darwin" }}
cat << EOF >> ~/.bashrc
bash $HOME/bin/change-wallpaper.sh
EOF

# yabai sudoers setting
echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d " " -f 1) $(which yabai) --load-sa" | sudo tee /private/etc/sudoers.d/yabai
{{ end }}

{{ if eq .chezmoi.os "linux" }}
sed -i "1ibash $HOME/bin/change-wallpaper.sh" ~/.zshrc

sudo sed -i -e "/^ *#Color$/c\ Color\n\ ILoveCandy" /etc/pacman.conf
sudo sed -i -e "/^ *#DefaultTimeoutStartSec=90s/c\ DefaultTimeoutStartSec=10s" /etc/systemd/system.conf
sudo sed -i -e "/^ *#DefaultTimeoutStopSec=90s/c\ DefaultTimeoutStopSec=10s" /etc/systemd/system.conf
sudo sed -i -e '/^ *exec -a/c\exec -a "$0" "$HERE/chrome" "$@" --gtk-version=4 --ozone-platform-hint=auto --enable-gpu-rasterization --enable-zero-copy \
--enable-features=TouchpadOverscrollHistoryNavigation --disable-smooth-scrolling --enable-fluent-scrollbars' /opt/google/chrome/google-chrome

sed -i -e "/^\$script:downloadBaseDir = ''/c\$script:downloadBaseDir = '/data/data/com.termux/files/home/storage/movies'" $HOME/TVerRec*/conf/user_setting.ps1
sed -i -e "/^\$script:downloadWorkDir = ''/c\$script:downloadWorkDir = '/tmp'" $HOME/TVerRec*/conf/user_setting.ps1
sed -i -e "/^\$script:saveBaseDir = ''/c\$script:saveBaseDir = '/data/data/com.termux/files/home/storage/movies'" $HOME/TVerRec*/conf/user_setting.ps1
sed -i -e "/^\$script:simplifiedValidation = \$false/c\$script:simplifiedValidation = \$true" $HOME/TVerRec*/conf/user_setting.ps1
sed -i -e "/^\$script:disableValidation = \$false/c\$script:disableValidation = \$true" $HOME/TVerRec*/conf/user_setting.ps1

cat << EOF | sudo tee -a /etc/environment
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
EOF

cat << EOF | sudo tee -a /etc/systemd/network/*.network
IPv6PrivacyExtensions=true
IgnoreCarrierLoss=3s
EOF

cat << EOF | tee -a ~/.xsessionrc
xinput set-prop 11 318 1
xinput --set-prop "Apple SPI Touchpad" "Coordinate Transformation Matrix" 4 0 0 0 4 0 0 0 1
EOF

cat << EOF | sudo tee -a /etc/X11/xorg.conf.d/51-synaptics-tweaks.conf
Section "InputClass"
  Identifier "touchpad"
  Driver "synaptics"
  MatchIsTouchpad "on"
    Option "Tapping" "True"
    Option "TappingDrag" "True"
    Option "DisableWhileTyping" "True"
    Option "CornerCoasting" "0"
    Option "CoastingSpeed" "20"
    Option "CoastingFriction" "50"
EndSection
EOF
{{ end }}
