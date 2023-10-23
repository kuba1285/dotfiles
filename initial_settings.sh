#!/bin/bash

chrome_flags="--force-dark-mode --enable-features=WebUIDarkMode --ozone-platform-hint=auto --enable-features=TouchpadOverscrollHistoryNavigation --gtk-version=4"

echo "$chrome_flags" >> /opt/google/chrome/google-chrome
