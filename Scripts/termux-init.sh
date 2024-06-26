cd
yes | pkg install termux-am termux-keyring termux-api termux-exec git curl which proot proot-distro pulseaudio termux-x11-nightly virglrenderer-android
termux-setup-storage
proot-distro install archlinux

touch ~/.hushlogin

#cat << EOF > $HOME/.bashrc
#pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
#pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
#export DISPLAY=:0
#termux-x11 :0 &
#virgl_test_server_android &
#am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity &&
#proot-distro login archlinux --shared-tmp ||

cat << EOF > $HOME/.bashrc
proot-distro login archlinux --shared-tmp
EOF

cat << EOF > $HOME/.termux/termux.properties
extra-keys = [ \\
		 ['ESC','|', '/', '~','HOME','UP','END'], \\
		 ['TAB', 'CTRL', '=', '-','LEFT','DOWN','RIGHT'] \\
		]
EOF
termux-reload-settings
exit
