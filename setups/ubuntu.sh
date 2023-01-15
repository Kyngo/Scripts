#!/bin/bash

if [ $EUID -ne 0 ]
then
    echo "Not running as root - exiting."
    exit 1
fi

#########################
# EXTERNAL DEB PACKAGES #
#########################

# DBeaver
wget https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb -O /tmp/dbeaver.deb
apt install /tmp/dbeaver.deb -yyq
# Discord
wget https://discord.com/api/download/stable\?platform\=linux\&format\=deb -O /tmp/discord.deb
apt install /tmp/discord.deb -yyq
# Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
apt install /tmp/chrome.deb -yyq
# VSCode
wget https://code.visualstudio.com/sha/download?build=stable\&os=linux-deb-x64 -O /tmp/vscode.deb
apt install /tmp/vscode.deb -yyq
# MS Edge
wget https://go.microsoft.com/fwlink?linkid=2149051&brand=M102 -O /tmp/ms-edge.deb
apt install /tmp/ms-edge.deb -yyq

#########################
# OS SELF UPDATE SCRIPT #
#########################

cp "$( dirname -- "$0"; )/update.sh" /usr/bin/update
chmod +x /usr/bin/update
update

###################################
# PACKAGES AND SNAPS INSTALLATION #
###################################

PKGS=(
    "python3" "docker.io" "docker-compose" "zip" "unzip" "virtualenv" "build-essential" "jq"
    "golang" "yakuake" "traceroute" "telegram-desktop" "lighttpd" "nmap" "gparted" "zsh" 
    "htop" "curl"
)

for i in ${PKGS[@]}
do
    apt install $i -yyq
done

SNAPS=(
    "postman" "mysql-workbench-community" "pycharm-community --classic" "spotify"
)
for i in ${SNAPS[@]}
do
    snap install $i
done

##########################
# OTHER PACKAGE MANAGERS #
##########################

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
# Poetry
curl -sSL https://install.python-poetry.org | python3 -
# SPHP
wget https://gist.githubusercontent.com/Kyngo/96f4f9ae48e98fa6d167f4d954f1eab0/raw/81e1b8b3dcb79ca13b6a402a2061a44b372a6261/sphp.sh  -O /usr/bin/sphp
chmod +x /usr/bin/sphp

# Installing Node.js versions
for ((i = 8; i <= 18; i++))
do
    nvm install $i
done
nvm alias default 18

#######################
# SHELL CUSTOMIZATION #
#######################

# Oh my Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

##############
# FINAL STEP #
##############

echo "Done! Reboot your terminal ASAP."
