#!/bin/bash

env_lines="GTK_IM_MODULE=fcitx\nQT_IM_MODULE=fcitx\nXMODIFIERS=@im=fcitx"

echo -e "$env_lines" >> /etc/environment

chrome_flags="--force-dark-mode --enable-features=WebUIDarkMode --ozone-platform-hint=auto --enable-features=TouchpadOverscrollHistoryNavigation --gtk-version=4"

echo "$chrome_flags" >> ~/opt/google/chrome/google-chrome
