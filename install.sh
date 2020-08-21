#!/bin/bash

statement(){
    echo -e "\e[93m\e[1m --> $1 \e[0m"
}

statementError(){
    echo -e "\e[91m\e[1m --> $1 \e[0m"
}

askQuestion(){
    options=(y n)
    statement "$1"
    read answer
    [[ " ${options[@]} " =~ " ${answer} " ]] || askQuestion "$1"
}

whichConfig(){
    statement "which config would you like to use
type a for x225
type b for chromebook"
    read config
    case $config in
        a)
            bash ~/ricingScripts/x225.sh
            ;;
        b)
            bash ~/ricingScripts/chromebook.sh
            ;;
        *)
            whichConfig
            ;;
    esac
}

# check whether the script is running as root
[[ $(id -u) -ne 0 ]] && statementError "please run the script as root" && exit 1 

# check the internet connection
[[ $(ping -c 1 -q google.com >&/dev/null; echo $?) -ne 0 ]] && statementError "you are not connected to the internet" && exit 1

# create a new user
statement "enter a name for a new user account"
read name
sed -i 's/%wheel ALL=(ALL) ALL/wheel ALL=(ALL) ALL/g' /etc/sudoers
useradd -m -g wheel -c \"$name\" -s /bin/bash $name
passwd $name

# git clone saved connections from my private repo (used by networkmanager)
askQuestion "do you want to git clone saved connections (y/n)"
if [[ $answer == y ]]; then
    if [[ -d /etc/NetworkManager/system-connections/ ]]; then
        cd /etc/NetworkManager/system-connections/
        rm -f /etc/NetworkManager/system-connections/
        git clone https://github.com/kelemen-jan/connections.git .
        rm -rf .git
        rm -f README.md
        chown root /etc/NetworkManager/system-connections/*.nmconnection
        chmod 600 /etc/NetworkManager/system-connections/*.nmconnection
    else
        statementError "/etc/NetworkManager/system-connections/ does not exist"
    fi
fi

# login as the new user and migrate the scripts to home folder
statement "migrating the scripts to home folder and logging as $name"
mv ~/ricingScripts /home/$name
chown -R $name /home/$name/ricingScripts
su - $name

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