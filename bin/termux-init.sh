cd
termux-setup-storage
yes | pkg install termux-keyring termux-api tsu termux-exec fakeroot git curl which proot proot-distro pulseaudio termux-x11-nightly virglrenderer-android
proot-distro install archlinux

touch ~/.hushlogin

cat << EOF > $HOME/startarch.sh
#!/data/data/com.termux/files/usr/bin/bash
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
# proot
command="proot"
command+=" --link2symlink -0"
# root directory folder
command+=" -r /data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/archlinux"
# specify some directories
command+=" -b /dev -b /proc "
# /dev/shm is a directory in memory (≈memory disk), which speeds up reading and writing, and does not need to be set.
command+=" -b /data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/archlinux/root:/dev/shm"
# Optional
command+=" -b \$ANDROID_DATA"
command+=" -b \$EXTERNAL_STORAGE"
command+=" -b \$HOME"
# It is best not to change the following
command+=" -w /root /usr/bin/env"
command+=" -i HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=en_US.UTF-8"
command+=" /bin/bash --login"
exec \$command
EOF

chmod +x ~/startarch.sh

cat << EOF > $HOME/.bashrc
eval "\$(starship init \$(ps -p \$\$ -o ucomm=))"
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
virgl_test_server_android &
 ~/startarch.sh
EOF

cat << EOF > $HOME/.termux/termux.properties
extra-keys = [ \\
		 ['ESC','|', '/', '~','HOME','UP','END'], \\
		 ['TAB', 'CTRL', '=', '-','LEFT','DOWN','RIGHT'] \\
		]
EOF
termux-reload-settings
exit
