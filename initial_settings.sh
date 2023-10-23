#!/bin/bash

nw_lines="IPv6PrivacyExtensions=true\nIgnoreCarrierLoss=3s"

echo -e "$nw_lines" >> /etc/systemd/network/10-wlan0.network

env_lines="GTK_IM_MODULE=fcitx\nQT_IM_MODULE=fcitx\nXMODIFIERS=@im=fcitx"

echo -e "$env_lines" >> /etc/environment

chrome_flags="--force-dark-mode --enable-features=WebUIDarkMode --ozone-platform-hint=auto --enable-features=TouchpadOverscrollHistoryNavigation --gtk-version=4"

echo "$chrome_flags" >> ~/opt/google/chrome/google-chrome
