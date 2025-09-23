#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for swapfile
if [ -f /swapfile ]; then

    # Removes existing swapfile
    sudo swapoff /swapfile
    sudo rm -v /swapfile
    sudo sed -i '/\/swapfile/d' /etc/fstab

else
    echo "${yellow}No swapfile detected ${reset}"
fi

# Prints a conclusive message
echo "${green}Swapfile removed ${reset}"
