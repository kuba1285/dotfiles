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

# set some colors
function set_colors() {
    if [ -t 1 ]; then
        RED=$(tput setaf 1)
        GREEN=$(tput setaf 2)
        YELLOW=$(tput setaf 3)
        CYAN=$(tput setaf 6)
        BOLD=$(tput bold)
        RESET=$(tput sgr0)
    else
        RED=""
        GREEN=""
        YELLOW=""
        CYAN=""
        BOLD=""
        RESET=""
    fi
}

# function that would show a progress bar to the user
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
            echo -n "${CYAN}NOTE${RESET} - Now installing $app ."
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

useradd -m -g users -G wheel,audio,video,storage -s /bin/bash user
echo user:user | chpasswd
sudo sed -i -e "/^ *root ALL=(ALL:ALL) ALL$/c\root ALL=(ALL:ALL) ALL\n\user ALL=(ALL) ALL" /etc/sudoers
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
sed -i -e "/^ *#ja_JP.UTF-8 UTF-8/c\ja_JP.UTF-8 UTF-8" /etc/locale.gen
locale-gen && echo "LANG=ja_JP.UTF-8" >> /etc/locale.conf

{{ if eq .chezmoi.os "darwin" }}
# Install CLI for Xcode
echo -n "${CYAN}NOTE${RESET} - Now installing CLI for Xcode."
xcode-select --install &>> $INSTLOG
show_progress $!

# Install rosetta
echo -n "${CYAN}NOTE${RESET} - Now installing rosetta."
sudo softwareupdate --install-rosetta --agree-to-licensesudo softwareupdate --install-rosetta --agree-to-license &>> $INSTLOG
show_progress $!

# Install homebrew
echo -n "${CYAN}NOTE${RESET} - Now installing Homebrew."
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" &>> $INSTLOG
show_progress $!

# Homebrew path setting
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc

# Install app from Brewfile
echo -n "${CYAN}NOTE${RESET} - Now installing Brewfile app."
brew bundle install --file $BIN/Brewfile &>> $INSTLOG
show_progress $!

# A bootplug to match the binary format so that yabai can inject code into the Dock of arm64 binaries.
if [[ $(uname -m) == 'arm64' ]]; then
    sudo nvram boot-args=-arm64e_preview_abi
    show_progress $!
fi

source $BIN/parse-plist

# Generate miscelenaeous file
brew bundle dump --force
parse-plist > parse-plist
sudo ln -s /Users/$USER/Documents /Users/$USER/Documents-ln
sudo ln -s /Users/$USER/Downloads /Users/$USER/Downloads-ln
sudo ln -s /Users/$USER/ /Users/$USER/$USER-ln

# Enable services
yabai --start-service
skhd --start-service
{{ end }}

{{ if eq .chezmoi.os "linux" }}
# Check for package manager
if [ ! -f /sbin/yay ] ; then  
    echo -n "${CYAN}NOTE${RESET} - Configuering yay."
    cd
    git clone https://aur.archlinux.org/yay.git &>> $INSTLOG
    cd yay && makepkg -si --noconfirm &>> $INSTLOG &
    show_progress $!
    cd
    rm -rf yay
    if [ -f /sbin/yay ] ; then
        echo "${GREEN}OK${RESET} - yay configured"
        cd ..
        echo -n "${CYAN}NOTE${RESET} - Updating yay."
        yay -Suy --noconfirm &>> $INSTLOG &
        show_progress $!
    else
        echo "${RED}ERROR${RESET} - yay install failed, please check the install.log"
        exit
    fi
fi

# Install listed pacakges
wait_yn "${YELLOW}ACITION${RESET} - Would you like to install apps from the list?"
if [[ $YN = y ]] ; then
    install_list $LISTAPP
fi

# Setup Nvidia if it was found
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia ; then
    install_list $LISTNVIDIA
    # update config
    sudo sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    sudo mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img
    echo -e "options nvidia-drm modeset=1" | sudo tee -a /etc/modprobe.d/nvidia.conf &>> $INSTLOG
    echo -e "WLR_NO_HARDWARE_CURSORS=1" | sudo tee -a /etc/environment
fi

# Install custom app
wait_yn "${YELLOW}ACITION${RESET} - Would you like to install custom app?"
if [[ $YN = y ]] ; then
    source $BIN/custom.sh &>> $INSTLOG &
    show_progress $!
fi

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

# Copy Config Files
wait_yn "${YELLOW}ACITION${RESET} - Would you like to copy config files?"
if [[ $YN = y ]] ; then
    cp -rT $PARENT/. ~/ &>> $INSTLOG &
    show_progress $!
fi

wait_yn "${YELLOW}ACITION${RESET} - Would you like to stage the files?"
if [[ $YN = y ]] ; then
    source $BIN/stage.sh &>> $INSTLOG &
    show_progress $!
fi

wait_yn "${YELLOW}ACITION${RESET} - Would you like to write to the config files?"
if [[ $YN = y ]] ; then
    source $BIN/write.sh &>> $INSTLOG &
    show_progress $!
fi

# Enable services
wait_yn "${YELLOW}ACITION${RESET} - Would you like to write to enable services?"
if [[ $YN = y ]] ; then
    for service in ${SERVICES[@]} ; do
        sudo systemctl enable $service --now &>> $INSTLOG
        sleep 2
    done
fi

pacman -R --noconfirm xfdesktop xfwm4-themes
sudo gpasswd -a $USER input
fc-cache -fv &>> $INSTLOG
{{ end }}

chsh -s $(which zsh) $USER
echo "${CYAN}NOTE${RESET} - Script had completed!"
