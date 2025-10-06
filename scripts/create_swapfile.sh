#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for swapfile
if [ ! -f /swapfile ]; then

    # Prompts the user for input
    read -rp "Enter size for swapfile [GiB]: " number

    # Checks that value is a positive number
    if [[ ! "$number" =~ ^[0-9]+$ ]]; then
        echo "${red}Value is not valid ${reset}"
        echo "${red}Enter a positive number ${reset}"
        exit 1
    fi

    # Checks that value is within limits
    if [ "$number" -gt 32 ]; then
        echo "${red}Value is too large ${reset}"
        echo "${red}Maximum allowed swapfile size is 32 GiB ${reset}"
        exit 1
    fi

    echo "${green}Swapfile size set to $number GiB ${reset}"

    # Define file system of root partition
    root_filesystem="$(df -T / | awk 'NR==2 {print $2}')"

    # Creates swapfile
    if [ "$root_filesystem" = "btrfs" ]; then
        sudo btrfs subvolume create /swap
        sudo btrfs filesystem mkswapfile --size "${number}g" --uuid clear /swap/swapfile
        sudo swapon /swap/swapfile
        echo '/swap/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab
        sudo swapon --show
    else
        sudo fallocate -l "${number}G" /swapfile
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile
        echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
        sudo swapon --show
    fi
else
    echo "${yellow}Swapfile detected ${reset}"
    exit 1
fi

# Prints a conclusive message
echo "${green}Swapfile created ${reset}"
