#!/bin/bash

# Define variables
TVERREC_URL=https://github.com/dongaba/TVerRec/archive/refs/tags/v3.0.2.tar.gz
ARCHIVE_NAME=$(basename $(echo $TVERREC_URL))
PARENT=$(cd $(dirname $0)/../; pwd)
BIN=$(cd $(dirname $0); pwd)
INSTLOG="$BIN/install.log"
LISTAPP="$BIN/list-app"
LISTNVIDIA="$BIN/list-nvidia"
SERVICES=(
    sddm
    bluetooth
    tlp
    mbpfan
)

function set_colors() {
    if [ -t 1 ]; then
        RED=$(tput setaf 1); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3);
        CYAN=$(tput setaf 6); BOLD=$(tput bold); RESET=$(tput sgr0)
    else
        RED=""; GREEN=""; YELLOW="";
        CYAN=""; BOLD=""; RESET=""
    fi
}

function show_progress() {
    while ps | grep $1 &> /dev/null ; do
        spin='⣾⣷⣯⣟⡿⢿⣻⣽'
        i=$(( (i+1) %8 ))
        printf "\r${spin:$i:1}"
        sleep .1
    done
    echo -en "Done!\n"
    sleep 2
}

function install_list() {
    while IFS= read -r app ; do
        echo -n "${CYAN}NOTE${RESET} - Now installing $app."
        yay -S --noconfirm --needed $app
        show_progress $!
    done < "$1"
}

function wait_yn(){
    YN="xxx"
    while [ $YN != 'y' ] && [ $YN != 'n' ] ; do
        read -p "$1 [y/n]" YN
    done
}
######

clear
set_colors

# give the user an option to exit
wait_yn "${YELLOW}ACITION${RESET} - Would you like to start with the install?"
if [[ $YN = y ]] ; then
    echo "${CYAN}NOTE${RESET} - Setup starting..."
    sudo touch /tmp/hyprv.tmp
else
    exit
fi

{{ if eq .chezmoi.os "darwin" }}
# Install CLI for Xcode
echo -n "${CYAN}NOTE${RESET} - Installing CLI for Xcode."
xcode-select --install &>> $INSTLOG
show_progress $!

# Install rosetta
echo -n "${CYAN}NOTE${RESET} - Installing Rosetta."
sudo softwareupdate --install-rosetta --agree-to-licensesudo softwareupdate --install-rosetta --agree-to-license &>> $INSTLOG
show_progress $!

# Install homebrew
echo -n "${CYAN}NOTE${RESET} - Installing Homebrew."
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" &>> $INSTLOG
show_progress $!

# Homebrew path setting
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bashrc

# Install app from Brewfile
echo -n "${CYAN}NOTE${RESET} - Installing Brewfile app."
brew bundle install --file $BIN/Brewfile &>> $INSTLOG
show_progress $!

# A bootplug to match the binary format so that yabai can inject code into the Dock of arm64 binaries.
if [[ $(uname -m) == 'arm64' ]]; then
    sudo nvram boot-args=-arm64e_preview_abi
fi

# Write default
source $BIN/parse-plist

# Generate misc file
sudo ln -s $HOME/Documents $HOME/Documents-ln
sudo ln -s $HOME/Downloads $HOME/Downloads-ln
sudo ln -s $HOME/ $HOME/$USER-ln
brew bundle dump --force
parse-plist > parse-plist

# Enable services
yabai --start-service
skhd --start-service
{{ end }}

{{ if (or (eq .chezmoi.os "darwin") (eq .chezmoi.os "linux")) }}
useradd -m -g users -G wheel,audio,video,storage -s /bin/bash user
echo user:user | chpasswd
sudo sed -i -e "/^ *root ALL=(ALL:ALL) ALL$/c\root ALL=(ALL:ALL) ALL\n\user ALL=(ALL) ALL" /etc/sudoers
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
sed -i -e "/^ *#ja_JP.UTF-8 UTF-8/c\ja_JP.UTF-8 UTF-8" /etc/locale.gen
locale-gen && echo "LANG=ja_JP.UTF-8" >> /etc/locale.conf

# Configure package manager
echo -n "${CYAN}NOTE${RESET} - Configuering yay."
cd
git clone https://aur.archlinux.org/yay.git &>> $INSTLOG
cd yay && makepkg -si --noconfirm &>> $INSTLOG &
show_progress $!
cd && rm -rf yay

# Setup Nvidia if found
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia ; then
    install_list $LISTNVIDIA
    sudo sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    sudo mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img
    echo -e "options nvidia-drm modeset=1" | sudo tee -a /etc/modprobe.d/nvidia.conf &>> $INSTLOG
    echo -e "WLR_NO_HARDWARE_CURSORS=1" | sudo tee -a /etc/environment
fi

# Install listed pacakges
echo -n "${CYAN}NOTE${RESET} - Installing apps from list."
install_list $LISTAPP

# Install custom app
echo -n "${CYAN}NOTE${RESET} - Installing custom app."
source $BIN/custom.sh &>> $INSTLOG &
show_progress $!

# Install MBP audio driver
wait_yn "${YELLOW}ACITION${RESET} - Would you like to install MBP audio driver?"
if [[ $YN = y ]] ; then
    cd
    git clone https://github.com/davidjo/snd_hda_macbookpro.git &>> $INSTLOG
    cd snd_hda_macbookpro/
    sudo ./install.cirrus.driver.sh &>> $INSTLOG &
    show_progress $!
    cd
fi

wait_yn "${YELLOW}ACITION${RESET} - Would you like to stage the files?"
if [[ $YN = y ]] ; then
    source $BIN/stage.sh &>> $INSTLOG &
    show_progress $!
fi

# Enable services
echo -n "${CYAN}NOTE${RESET} - Enabling services."
for service in ${SERVICES[@]} ; do
    sudo systemctl enable $service --now &>> $INSTLOG
    sleep 2
done

pacman -R --noconfirm xfdesktop xfwm4-themes
sudo gpasswd -a $USER input
fc-cache -fv &>> $INSTLOG
{{ end }}

# Copy Config Files
echo -n "${CYAN}NOTE${RESET} - Copying config files."
cp -rT $PARENT/. ~/ &>> $INSTLOG &
show_progress $!

echo -n "${CYAN}NOTE${RESET} - Wrinting to config files."
source $BIN/write.sh &>> $INSTLOG &
show_progress $!

chsh -s $(which zsh) $USER
echo "${CYAN}NOTE${RESET} - Script had completed!"
