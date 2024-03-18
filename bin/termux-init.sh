cd
termux-setup-storage
yes | pkg install termux-keyring termux-api tsu termux-exec fakeroot git curl which proot proot-distro pulseaudio termux-x11-nightly
proot-distro install archlinux

echo "proot-distro login archlinux" >> $HOME/.bashrc
touch .hushlogin

cat << EOF >> $HOME/.termux/termux.properties
extra-keys = [ \\
		 ['ESC','|', '/', '~','HOME','UP','END'], \\
		 ['TAB', 'CTRL', '=', '-','LEFT','DOWN','RIGHT'] \\
		]
EOF
termux-reload-settings
exit
