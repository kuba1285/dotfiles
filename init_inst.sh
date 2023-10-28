#!/bin/bash

# update list
sudo pacman -Syu

sudo pacman -S --needed --noconfirm git wget man-db blueman bluez bluez-utils reflector pacman-contrib waybar pavucontrol alsa-utils neofetch gtk4 meson cmake seatd wl-clipboard ttf-font-awesome

sudo systemctl start bluetooth systemd-timesyncd systemd-networkd systemd-resolved paccache.timer --now

reflector --sort rate --country jp --latest 10 --save /etc/pacman.d/mirrorlist

git clone https://aur.archlinux.org/yay.git /tmp/yay &&
cd /tmp/yay &&
makepkg -si

yay -S --noconfirm google-chrome ttf-menlo-powerline-git rofi-lbonn-wayland

fc-cache -vf

git clone https://github.com/WayfireWM/wf-install &&
cd wf-install &&
./install.sh --prefix /opt/wayfire --stream master

nw_lines="IPv6PrivacyExtensions=true\nIgnoreCarrierLoss=3s"
env_lines="GTK_IM_MODULE=fcitx\nQT_IM_MODULE=fcitx\nXMODIFIERS=@im=fcitx"
chrome_flags="--force-dark-mode --enable-features=WebUIDarkMode --ozone-platform-hint=auto --enable-features=TouchpadOverscrollHistoryNavigation --gtk-version=4"

echo -e "$env_lines" >> /etc/environment
echo -e "$nw_lines" >> /etc/systemd/network/10-wlan0.network
echo "$chrome_flags" >> /opt/google/chrome/google-chrome
