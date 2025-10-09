#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for swapfile
if [[ -f /swapfile || -f /swap/swapfile ]]; then

    # Define file system of root partition
    root_filesystem="$(df -T / | awk 'NR==2 {print $2}')"

    # Checks for filesystem and removes swapfile
    if [ "$root_filesystem" = "btrfs" ]; then
        sudo swapoff /swap/swapfile
        sudo rm -v /swap/swapfile
        sudo btrfs subvolume delete /swap
        sudo sed -i '/\/swap\/swapfile/d' /etc/fstab

    else
        sudo swapoff /swapfile
        sudo rm -v /swapfile
        sudo sed -i '/\/swapfile/d' /etc/fstab
    fi

else
    echo "${yellow}No swapfile detected ${reset}"
    exit 1
fi

# Prints a conclusive message
echo "${green}Swapfile removed ${reset}"
