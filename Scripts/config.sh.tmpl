#!{{ lookPath "bash" }}

# Write run commands
cat << EOF >> ~/.bashrc
bash $HOME/Scripts/change-wallpaper.sh
neowofetch --gap -30 --ascii "\$(fortune -s | pokemonsay -w 30)"
EOF

# TverRec settings
mkdir -p $HOME/Downloads
sed -i -e "/^\$script:downloadBaseDir = ''/c\$script:downloadBaseDir = '$DLDIR'" $HOME/TVerRec*/conf/user_setting.ps1
sed -i -e "/^\$script:downloadWorkDir = ''/c\$script:downloadWorkDir = '/tmp'" $HOME/TVerRec*/conf/user_setting.ps1
sed -i -e "/^\$script:saveBaseDir = ''/c\$script:saveBaseDir = '$DLDIR'" $HOME/TVerRec*/conf/user_setting.ps1
sed -i -e "/^\$script:simplifiedValidation = \$false/c\$script:simplifiedValidation = \$true" $HOME/TVerRec*/conf/user_setting.ps1
sed -i -e "/^\$script:disableValidation = \$false/c\$script:disableValidation = \$true" $HOME/TVerRec*/conf/user_setting.ps1
mv -f $HOME/src/keyword.conf $HOME/TVerRec*/conf/keyword.conf

{{ if eq .chezmoi.os "darwin" }}

# Generate misc file
sudo ln -s $HOME/Documents $HOME/Documents-ln
sudo ln -s $HOME/Downloads $HOME/Downloads-ln
sudo ln -s $HOME/ $HOME/$USER-ln

# Write default
wait_yn "${YELLOW}ACITION${RESET} - Would you like to execute parse-plist?"
if [[ $YN = y ]] ; then
    echo "${CYAN}NOTE${RESET} - Executing parse-plist."
    source $HOME/Documents/parse-plist
fi

# A bootplug to match the binary format so that yabai can inject code into the Dock of arm64 binaries.
if [[ $(uname -m) == 'arm64' ]]; then
    sudo nvram boot-args=-arm64e_preview_abi
fi

# yabai sudoers setting
echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d " " -f 1) $(which yabai) --load-sa" | sudo tee /private/etc/sudoers.d/yabai
yabai --start-service
skhd --start-service

{{ end }}

{{ if eq .chezmoi.os "linux" }}

sudo sed -i -e '/^ *exec -a/c\exec -a "$0" "$HERE/chrome" "$@" --gtk-version=4 --ozone-platform-hint=auto --enable-gpu-rasterization --enable-zero-copy \
--enable-features=TouchpadOverscrollHistoryNavigation --disable-smooth-scrolling --enable-fluent-scrollbars' /opt/google/chrome/google-chrome
sudo sed -i -e '/#DefaultTimeoutSt/s/90s/10s/' -e '/#DefaultTimeoutSt/s/^#//' /etc/systemd/system.conf

cat << EOF | sudo tee -a /etc/systemd/network/*.network
IPv6PrivacyExtensions=true
IgnoreCarrierLoss=3s
EOF

cat << EOF | sudo tee -a /etc/environment
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
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

    {{ if eq .chezmoi.osRelease.id "archarm" }}

sudo cp /etc/X11/xinit/xinitrc ~/.xinitrc
sudo sed -i -e '/^twm/s/^/#/ -e '/^xclock/s/^/#/' -e '/^xterm/s/^/#/g' ~/.xinitrc
cat << EOF >> ~/.xinitrc
sxhkd & exec bspwm
EOF

# Remote resolution mode settings
cat << EOF >> ~/.xprofile
#!/bin/sh
xrandr --newmode $MODELINE
xrandr --addmode $DISP $MODERES
xrandr -s $(cvt $(echo $RES) | grep -e "Modeline [^(]" | cut -d " " -f 2)
EOF

    {{ end }}

chmod +x $EXECUTABLES
sudo gpasswd -a $USER input
chsh -s $(which zsh) $USER

# VNC server settings
vncpasswd $HOME/.vnc/passwd

# Enable services
echo "${CYAN}NOTE${RESET} - Enabling services."
for service in ${SERVICES[@]} ; do
    sudo systemctl enable $service
    sleep 2
done

{{ end }}
