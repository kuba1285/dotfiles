#!/bin/bash

{{ if eq .chezmoi.os "darwin" }}

pipx install pywal
pipx ensurepath

cd
git clone https://github.com/Nellousan/px2ansi.git
cd px2ansi
pipx install .

{{ end }}

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

go install github.com/orangekame3/paclear@latest

cd
git clone http://github.com/possatti/pokemonsay &>> $INSTLOG
cd pokemonsay
./install.sh &>> $INSTLOG

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
cp $PARENT/src/keyword.conf > keyword.conf
source $BIN/write.sh

cd
wget https://github.com/autopawn/3d-ascii-viewer/archive/refs/tags/v1.4.0.tar.gz
tar xvzf v1.4.0.tar.gz && cd 3d-ascii-viewer*
make
find ./models -name "*.mtl" -type f | xargs rm
mv 3d-ascii-viewer models/ $HOME/bin/.
cd && rm -rf 3d-ascii-viewer* v1.4.0.tar.gz
