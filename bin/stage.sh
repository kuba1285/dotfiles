#!{{ lookPath "bash" }}

chmod +x ~/.config/polybar/scripts/*
chmod +x ~/.config/hypr/scripts/*
yay -R --noconfirm xfdesktop xfwm4-themes &>> $INSTLOG

# add VScode extensions
mkdir ~/.vscode
tar -xf $PARENT/src/extensions.tar.gz -C ~/.vscode/

# Copy the SDDM theme
sudo tar -xf $PARENT/src/sugar-candy.tar.gz -C /usr/share/sddm/themes/
sudo chown -R $USER:$USER /usr/share/sddm/themes/sugar-candy
sudo mkdir /etc/sddm.conf.d
echo -e "[Theme]\nCurrent=sugar-candy" | sudo tee -a /etc/sddm.conf.d/10-theme.conf
