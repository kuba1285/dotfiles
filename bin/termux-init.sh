cd
termux-setup-storage
yes | pkg install termux-keyring termux-api termux-exec git curl which proot proot-distro pulseaudio termux-x11-nightly virglrenderer-android
proot-distro install archlinux

touch ~/.hushlogin

cat << EOF > $HOME/.bashrc
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
virgl_test_server_android &
proot-distro login --user user --shared-tmp archlinux
EOF

cat << EOF > $HOME/.termux/termux.properties
extra-keys = [ \\
		 ['ESC','|', '/', '~','HOME','UP','END'], \\
		 ['TAB', 'CTRL', '=', '-','LEFT','DOWN','RIGHT'] \\
		]
EOF
termux-reload-settings
useradd -U -m user
exit
