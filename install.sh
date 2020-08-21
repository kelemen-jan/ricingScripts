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
        rm -f /etc/NetworkManager/system-connections/*
        git clone https://github.com/kelemen-jan/connections.git .
        rm -rf .git
        rm -f README.md
        chown root /etc/NetworkManager/system-connections/*.nmconnection
        chmod 600 /etc/NetworkManager/system-connections/*.nmconnection
    else
        statementError "/etc/NetworkManager/system-connections/ does not exist"
    fi
fi

# migrate the scripts to home folder
statement "migrating the scripts to $name's home folder"
mv ~/ricingScripts /home/$name
chown -R $name /home/$name/ricingScripts
su -c "bash ~/ricingScripts/runAsUser.sh" - $name