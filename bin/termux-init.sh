cd
termux-setup-storage
yes | pkg install termux-keyring termux-api tsu termux-exec fakeroot git curl which proot proot-distro pulseaudio termux-x11-nightly
proot-distro install archlinux

echo　<< EOF >> $HOME/.bashrc
proot-distro login archlinux
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
EOF

cat << EOF >> $HOME/.termux/termux.properties
extra-keys = [ \\
		 ['ESC','|', '/', '~','HOME','UP','END'], \\
		 ['TAB', 'CTRL', '=', '-','LEFT','DOWN','RIGHT'] \\
		]
EOF
termux-reload-settings
exit
