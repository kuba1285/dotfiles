#!/bin/bash

# update list
sudo pacman -Syu

sudo pacman -S --needed --noconfirm git wget wl-clipboard man-db blueman bluez bluez-utils reflector pacman-contrib waybar ttf-font-awesome pavucontrol alsa-utils neofetch gtk4

# wayfire dependencies
sudo pacman -S --needed --noconfirm glm meson cmake seatd mpd

sudo systemctl enable bluetooth systemd-timesyncd systemd-networkd systemd-resolved paccache.timer --now

reflector --sort rate --country jp --latest 10 --save /etc/pacman.d/mirrorlist

git clone https://aur.archlinux.org/yay.git &&
cd yay &&
makepkg -si

yay -S --noconfirm google-chrome ttf-menlo-powerline-git rofi-lbonn-wayland

fc-cache -vf

git clone https://github.com/WayfireWM/wf-install &&
cd wf-install &&
./install.sh --prefix /opt/wayfire --stream master

nw_lines="IPv6PrivacyExtensions=true\nIgnoreCarrierLoss=3s"
env_lines="GTK_IM_MODULE=fcitx\nQT_IM_MODULE=fcitx\nXMODIFIERS=@im=fcitx"
chrome_flags="--force-dark-mode --enable-features=WebUIDarkMode --ozone-platform-hint=auto --enable-features=TouchpadOverscrollHistoryNavigation --gtk-version=4"

sudo echo -e "$env_lines" | sudo tee -a /etc/environment
sudo echo -e "$nw_lines" | sudo tee -a /etc/systemd/network/10-wlan0.network
sudo echo "$chrome_flags" | sudo tee -a /opt/google/chrome/google-chrome
