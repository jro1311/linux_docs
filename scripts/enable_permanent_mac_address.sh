#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Checks for package and copies config(s)
if command -v nmcli > /dev/null 2>&1; then
    echo "${green}Detected: Network Manager ${reset}"
    
    if ! grep -Fq "wifi.cloned-mac-address=permanent" /etc/NetworkManager/NetworkManager.conf; then
        sudo cp -v "$HOME/Documents/linux_docs/configs/packages/10-permanent-mac-address.conf" /etc/NetworkManager/conf.d/
        sudo systemctl restart NetworkManager
        
    else
        echo "${green}Permanent MAC address already enabled ${reset}"
    fi
    
else
    echo "${red}Network Manager not detected ${reset}"
    exit 1
fi

# Prints a conclusive message
echo "${green}Permanent MAC address enabled ${reset}"
