#!/bin/bash

statement(){
    echo -e "\e[93m\e[1m --> $1 \e[0m"
}

statementError(){
    echo -e "\e[91m\e[1m --> $1 \e[0m"
}

# move xinitrc
statement "moving xinitrc"
mv ~/ricingScripts/xinitrc_x225 ~/.xinitrc