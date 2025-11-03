#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Define file system of root directory
root_filesystem="$(df -T / | awk 'NR==2 {print $2}')"
echo "${green}Detected Root File System: $root_filesystem ${reset}"

# Checks for swapfile and removes it
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
    echo "${yellow}No swapfile detected ${reset}"
    exit 1
fi

# Prints a conclusive message
echo "${green}Swapfile removed. ${reset}"
