#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for package and copies config(s)
if command -v nmcli > /dev/null 2>&1; then
    echo "${green}Detected: Network Manager ${reset}"

    sudo mkdir -pv /etc/NetworkManager/conf.d
    
    if [ ! -f /etc/NetworkManager/conf.d/10-permanent-mac-address.conf ]; then

        sudo cp -v "$HOME/Documents/linux_docs/configs/packages/network_manager/10-permanent-mac-address.conf" /etc/NetworkManager/conf.d/

        if command -v systemctl > /dev/null 2>&1; then
            sudo systemctl restart NetworkManager
        fi
        
    else
        echo "${green}Permanent MAC address is already enabled ${reset}"
    fi
    
else
    echo "${yellow}Network Manager not detected ${reset}"
fi

# Prints a conclusive message
echo "${green}Permanent MAC address enabled. ${reset}"
