#!{{ lookPath "bash" }}

chmod +x $HOME/.config/polybar/scripts/*
chmod +x $HOME/.config/hypr/scripts/*
yay -R --noconfirm xfdesktop xfwm4-themes

# add VScode extensions
mkdir $HOME/.vscode
tar -xf $HOME/src/extensions.tar.gz -C ~/.vscode/

# Copy the SDDM theme
sudo tar -xf $HOME/src/sugar-candy.tar.gz -C /usr/share/sddm/themes/
sudo chown -R $USER:$USER /usr/share/sddm/themes/sugar-candy
sudo mkdir /etc/sddm.conf.d
echo -e "[Theme]\nCurrent=sugar-candy" | sudo tee -a /etc/sddm.conf.d/10-theme.conf
