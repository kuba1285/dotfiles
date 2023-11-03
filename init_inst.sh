#!/bin/bash

cd
# general packages
sudo pacman -Syu
sudo pacman -S --needed --noconfirm nvidia neofetch git wget firefox wl-clipboard man-db blueman bluez bluez-utils reflector pacman-contrib pavucontrol alsa-utils gtk4
reflector --sort rate --country jp --latest 10 --save /etc/pacman.d/mirrorlist

# aur
git clone https://aur.archlinux.org/yay-bin.git &&
cd yay-bin &&
makepkg -si
yay -S --noconfirm google-chrome archlinux-themes-sddm ttf-menlo-powerline-git rofi-lbonn-wayland
fc-cache -vf

# add dm here as needed
sudo systemctl enable iwd bluetooth systemd-timesyncd systemd-networkd systemd-resolved paccache.timer --now

# waybar
sudo pacman -S --needed --noconfirm waybar mpd ttf-font-awesome

# wf-install
sudo pacman -S --needed --noconfirm glm meson cmake seatd
git clone https://github.com/WayfireWM/wf-install &&
cd wf-install &&
./install.sh --prefix /opt/wayfire --stream master

# rewrite files
sudo sed -i -e "/^ *#Color$/c\ Color\n\ ILoveCandy" /etc/pacman.conf
sudo sed -i -e "/^ *#DefaultTimeoutStartSec=/c\ DefaultTimeoutStartSec=10s" /etc/systemd/system.conf
sudo sed -i -e "/^ *#DefaultTimeoutStopSec=/c\ DefaultTimeoutStopSec=10s" /etc/systemd/system.conf
sudo sed -i -e "/^ *#Current=$/c\ Current=archlinux-simplyblack" /usr/lib/sddm/sddm.conf.d/default.conf

# append to files
env_lines="GTK_IM_MODULE=fcitx\nQT_IM_MODULE=fcitx\nXMODIFIERS=@im=fcitx"
nw_lines="IPv6PrivacyExtensions=true\nIgnoreCarrierLoss=3s"
sudo echo -e "$env_lines" | sudo tee -a /etc/environment
sudo echo -e "$nw_lines" | sudo tee -a /etc/systemd/network/10-wlan0.network

# with nvidia gpu
sc_lines="WLR_NO_HARDWARE_CURSORS=1"
sudo echo -e "$sc_lines" | sudo tee -a /etc/environment

# also available in .config/chrome-flags.conf
#chrome_flags="--force-dark-mode --enable-features=WebUIDarkMode --ozone-platform-hint=auto --enable-features=TouchpadOverscrollHistoryNavigation --gtk-version=4"
#sudo echo "$chrome_flags" | sudo tee -a /opt/google/chrome/google-chrome
