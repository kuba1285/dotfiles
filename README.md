Just run:
```sh
yes | pkg update && pkg install curl
curl -s https://raw.githubusercontent.com/kuba1285/termux-dotfiles/master/bin/init.sh | bash
```
and then:
```sh
cd
git clone https://github.com/kuba1285/termux-dotfiles && cd termux-dotfiles
chmod +x ./bin/install.sh
./bin/install.sh
```
