#!/usr/bin/env bash

set -o nounset # if an unset variable is being read, the script will halt
set -o pipefail # if a command in a pipe fails, the script will halt

# Do we want to debug this script?
if [[ "${TRACE-0}" == "1" ]]; then
  set -o xtrace
fi

# Help function
do_help() {
  echo '
  Usage: '${0}' [--help|--install]

  -h | --help     ->  will show this message and exit the program
  -i | --install  ->  install the script in a system-wide directory (/usr/bin)

  Opening the script with the env variable "TRACE" set to "1" will enable the "xtrace" bash mode to debug the code.
'
  exit 0
}

# OS Basic updates
do_os_update() {
  sudo apt --fix-broken install
  sudo dpkg --configure -a
  sudo apt update
  sudo apt upgrade -y -q
  sudo apt autoremove -y -q
  sudo apt purge -y -q
}

# Additional OS updates
do_additional_os_updates() {
  sudo update-grub2
}

# Custom updates
do_custom_updates() {
  SRV_DBEAVER_VER=`curl -Is https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb | grep Location | cut -f5 -d"/"`
  APT_DBEAVER_VER=`apt list dbeaver-ce | cut -f2 -d" " | grep -v List 2> /dev/null`

  if [[ "$SRV_DBEAVER_VER" == "$APT_DBEAVER_VER" ]]; then
    echo "DBeaver is already up to date!"
  else
    echo "Updating DBeaver..."
    cd /tmp
    wget https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb -O dbeaver.deb
    sudo apt install ./dbeaver.deb
    cd
  fi
}

# Update snaps
do_snap_updates() {
  FIREFOX_IS_RUNNING=`ps aux | grep firefox | grep -v grep`
  sudo killall firefox
  sudo snap refresh
  if [[ -f "$HOME/nohup.out" ]]; then
    rm $HOME/nohup.out
  fi
  if [[ "$FIREFOX_IS_RUNNING" != "" ]]; then
    nohup firefox > /dev/null 2>&1 &
  fi
}

# Check if the OS needs a reboot
do_reboot_check() {
  if [[ -f /var/run/reboot-required ]]; then
    echo "The system needs to reboot! Do it ASAP."
  fi
}

# Update function
do_update()  {
  do_os_update
  do_additional_os_updates
  do_custom_updates
  do_snap_updates
  do_reboot_check
  exit 0
}

# Install function
do_install() {
  if [[ "$0" == "/usr/bin/update" ]]; then
    echo "Script is already installed!"
    exit 0
  fi
  chmod +x $0
  cp $0 /usr/bin/update > /dev/null 2>&1
  if [[ $? -eq 0 ]]; then
    echo "Script installed successfully!"
  else
    echo "Failed to install the script!"
  fi
}

# Main function
do_main() {
  which apt > /dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    echo "This OS is not compatible with this update script!"
    exit 1
  fi
  set -o errexit # if something fails, the script will halt
  echo "Verifying permissions... You may be asked for your password by the 'sudo' command."
  sudo -v
  echo "Granted access, updating system..."
  do_update
}

# Startup logic
if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
  do_help
elif [[ "${1-}" =~ ^-*i(nstall)?$ ]]; then
  do_install
else
  do_main
fi
