#!/bin/bash

# install yay
statement "installing yay"
git clone https://aur.archlinux.org/yay.git
cd ~/yay
makepkg -si
rm -rf ~/yay

# git clone the dotfiles
statement "cloning dotfiles"
cd
git clone https://github.com/kelemen-jan/dotfiles.git .

# build the suckless software
statement "installing the suckless software"
cd .local/src/dwm && sudo make clean install
cd .local/src/st && sudo make clean install
cd .local/src/dmenu && sudo make clean install

# git clone the ssh key from my private repo
askQuestion "do you want to git clone the ssh key (y/n)"
if [[ $answer == y ]]; then
    mkdir ~/.ssh
    cd ~/.ssh
    git clone https://github.com/kelemen-jan/sshKey.git .
    rm -rf .git
    rm -f README.md
fi

# enable fstrim.timer
askQuestion "do you want to enable fstrim.timer service (y/n)"
if [[ $answer == y ]]; then
    sudo systemctl enable fstrim.timer
fi

# add user to the video group (coz light)
statement "adding $name to the video group"
sudo usermod -a -G video $name

# set zsh as default shell
statement "setting zsh as defualt shell"
sudo chsh -s /bin/zsh $name

# pacman mirrors
statement "switching to Slovakian mirror"
sudo sh -c "echo 'Server = https://mirror.lnx.sk/pub/linux/archlinux/\$repo/os/\$arch' > /etc/pacman.d/mirrorlist"

# install all the packages
statement "installing all the packages"
yay -Syu --noconfirm
packages="
xorg-server xorg-xinit
noto-fonts-emoji noto-fonts-cjk noto-fonts-extra
lf pcmanfm-gtk3  file-roller
neovim vi
mpv
man-db
youtube-dl
zsh-fast-syntax-highlighting
highlight
xdotool xcape
dosfstools exfat-utils ntfs-3g
light
rofi papirus-icon-theme
sxhkd
bitwise speedcrunch
chromium
"
yay -S --noconfirm $packages
# add these to the packages variable: code, firefox, tlp, powertop

# run specific scripts
whichConfig

statement "the script is done, please reboot your pc"

# remove the ricing scripts
rm -rf ~/ricingScripts