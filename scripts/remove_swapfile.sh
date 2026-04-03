#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

host_system="unknown"
primary_package_manager="unknown"
init_system="unknown"
root_filesystem="unknown"

# Sources all .sh files in $HOME/Documents/linux_docs/configs/system/bash/bashrc.d
shopt -s globstar nullglob

# shellcheck source=/dev/null
for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f "$rc" ]] && source "$rc"
done
unset rc

shopt -u globstar nullglob

if [ "$host_system" != "unknown" ]; then
    green_message "Host System:" "$host_system"
fi

if [ "$primary_package_manager" != "unknown" ]; then
    green_message "Primary Package Manager:" "$primary_package_manager"
fi

if [ "$init_system" != "unknown" ]; then
    green_message "Init System:" "$init_system"
fi

green_message "Root File System:" "$root_filesystem"
read -r -p "Press enter to proceed, or ctrl+c to cancel: "

# Removes detected swapfile
if [ -f /swapfile ]; then
    sudo swapoff /swapfile
    sudo rm -v /swapfile
    sudo sed -i '/\/swapfile/d' /etc/fstab

elif [ -f /swap/swapfile ]; then
    sudo swapoff /swap/swapfile
    sudo rm -v /swap/swapfile
    sudo sed -i '/\/swap\/swapfile/d' /etc/fstab

    if [ "$root_filesystem" = "btrfs" ]; then
        sudo btrfs subvolume delete /swap
    fi

elif [ -f /swap.img ]; then
    sudo swapoff /swap.img
    sudo rm -v /swap.img
    sudo sed -i '/\/swap.img/d' /etc/fstab

else
    yellow_message "No swapfile detected."
    exit 1
fi

# Prompts the user to disable zswap
if grep -Fq "Y" /sys/module/zswap/parameters/enabled; then
    if ask_for_confirmation "Disable zswap and install zram?"; then
        disable_zswap
        install_zram
    fi
fi

green_message "Swapfile removed."
