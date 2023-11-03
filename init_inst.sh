#!/bin/bash

# update list
sudo pacman -Syu

sudo pacman -S --needed --noconfirm git nvidia wget firefox wl-clipboard man-db blueman bluez bluez-utils reflector pacman-contrib pavucontrol alsa-utils neofetch gtk4

reflector --sort rate --country jp --latest 10 --save /etc/pacman.d/mirrorlist

# wf-install dependencies
sudo pacman -S --needed --noconfirm glm meson cmake seatd

# waybar dependencies
sudo pacman -S --needed --noconfirm waybar mpd ttf-font-awesome

sudo systemctl enable bluetooth systemd-timesyncd systemd-networkd systemd-resolved paccache.timer --now

git clone https://aur.archlinux.org/yay-bin.git &&
cd yay &&
makepkg -si

yay -S --noconfirm google-chrome archlinux-themes-sddm ttf-menlo-powerline-git rofi-lbonn-wayland

fc-cache -vf

#conf rewrite
#sudo sed -i -e "/^ *#Current=$/c\ Current=archlinux-simplyblack" /usr/lib/sddm/sddm.conf.d/default.conf
#sudo sed -i -e "/^ *#DefaultTimeoutStartSec=/c\ DefaultTimeoutStartSec=10s" /etc/systemd/system.conf
#sudo sed -i -e "/^ *#DefaultTimeoutStopSec=/c\ DefaultTimeoutStopSec=10s" /etc/systemd/system.conf
#sudo sed -i -e "/^ *#Color$/c\ Color" /etc/pacman.conf

git clone https://github.com/WayfireWM/wf-install &&
cd wf-install &&
./install.sh --prefix /opt/wayfire --stream master

env_lines="GTK_IM_MODULE=fcitx\nQT_IM_MODULE=fcitx\nXMODIFIERS=@im=fcitx"
nw_lines="IPv6PrivacyExtensions=true\nIgnoreCarrierLoss=3s"

sudo echo -e "$env_lines" | sudo tee -a /etc/environment
sudo echo -e "$nw_lines" | sudo tee -a /etc/systemd/network/10-wlan0.network

# also available in .config/chrome-flags.conf
#chrome_flags="--force-dark-mode --enable-features=WebUIDarkMode --ozone-platform-hint=auto --enable-features=TouchpadOverscrollHistoryNavigation --gtk-version=4"
#sudo echo "$chrome_flags" | sudo tee -a /opt/google/chrome/google-chrome

# wayfire software cursor
sc_lines="WLR_NO_HARDWARE_CURSORS=1"
sudo echo -e "$sc_lines" | sudo tee -a /etc/environment
