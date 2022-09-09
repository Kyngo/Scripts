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

#########################
# OS SELF UPDATE SCRIPT #
#########################

cat > /usr/bin/update << EOF
#!/bin/bash
if [ $EUID -ne 0 ]
then
    echo "Not running as root - exiting."
    exit 1
fi
sudo snap refresh
sudo apt --fix-broken install
sudo dpkg --configure -a
sudo apt update
sudo apt upgrade -yyq
sudo apt autoremove -yyq
sudo apt purge -yyq
sudo update-grub2

if [ -f /var/run/reboot-required ]; then
  echo "The system needs to reboot! Do it ASAP."
fi
EOF
chmod +x /usr/bin/update
update

###################################
# PACKAGES AND SNAPS INSTALLATION #
###################################

PKGS=(
    "python3" "code" "google-chrome-browser" "docker.io" "docker-compose" "zip" "unzip" "virtualenv" "php7.4" 
    "php7.4-gd" "php7.4-mbstring" "php7.4-zip" "php7.4-xml" "php7.4-json" "php7.4-mysqli" "build-essential" "jq" 
    "php8.0-gd" "php8.0-mbstring" "php8.0-zip" "php8.0-xml" "php8.0-mysqli" "php8.1" "php8.1-fpm" "php8.1-gd" 
    "php8.1-mbstring" "php8.1-zip" "php8.1-xml" "php8.1-mysqli" "apache2" "libapache2-mod-php7.4"
    "libapache2-mod-php8.0" "traceroute" "telegram-desktop" "gitweb" "lighttpd" "nmap" "gparted" "zsh" "htop"
)

for i in ${PKGS[@]}
do
    apt install $i -yyq
done

SNAPS=(
    "postman" "mysql-workbench-community" "pycharm-community --classic"
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
# Poetry
curl -sSL https://install.python-poetry.org | python3 -
# SPHP
wget https://gist.githubusercontent.com/Kyngo/96f4f9ae48e98fa6d167f4d954f1eab0/raw/81e1b8b3dcb79ca13b6a402a2061a44b372a6261/sphp.sh > /usr/bin/sphp
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
