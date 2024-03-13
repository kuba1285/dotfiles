#!/bin/sh

TVERREC_URL=https://github.com/dongaba/TVerRec/archive/refs/tags/v3.0.2.tar.gz
ARCHIVE_NAME=$(basename $(echo $TVERREC_URL))
BIN=$(cd $(dirname $0); pwd)
PARENT=$(cd $(dirname $0)/../; pwd)
LISTAPP="$BIN/list-app"

# function for install app from list
function install_list() {
        while IFS= read -r app ; do
            pacman -S --noconfirm --needed $app
        done < "$1"
}

######
clear

useradd -m -g users -G wheel,audio,video,storage -s /bin/bash user
echo root:root | chpasswd
echo user:user | chpasswd
sudo sed -i -e "/^ *root ALL=(ALL:ALL) ALL$/c\root ALL=(ALL:ALL) ALL\n\user ALL=(ALL) ALL" /etc/sudoers
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
sed -i -e "/^ *#ja_JP.UTF-8 UTF-8/c\ja_JP.UTF-8 UTF-8" /etc/locale.gen
locale-gen
echo "LANG=ja_JP.UTF-8" >> /etc/locale.conf

pacman --noconfirm -Syyu
install_list $LISTAPP

cd
go install github.com/orangekame3/paclear@latest

cd
git clone http://github.com/possatti/pokemonsay && cd pokemonsay
./install.sh

cd
mkdir powershell && cd powershell
wget https://github.com/PowerShell/PowerShell/releases/download/v7.2.13/powershell-7.2.13-linux-arm64.tar.gz
tar xvzf powershell-7.2.13-linux-arm64.tar.gz
ln -s $HOME/powershell/pwsh /usr/bin/pwsh

cd
wget $TVERREC_URL
tar xvzf $ARCHIVE_NAME
rm $ARCHIVE_NAME

cd $HOME/TVerRec*/conf/
cp system_setting.ps1 user_setting.ps1
curl -s https://raw.githubusercontent.com/kuba1285/termux-dotfiles/master/src/keyword.conf > keyword.conf
source $BIN/write.sh

cp -rT $PARENT/. $HOME/
pacman -R xfdesktop xfwm4-themes
chsh -s $(which zsh) $USER
source $HOME/.zprofile
