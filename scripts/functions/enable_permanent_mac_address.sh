#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for Network Manager and enables permanent MAC address
if command -v nmcli > /dev/null 2>&1; then
    echo "${green}Detected: Network Manager ${reset}"
    
    if [ ! -f /etc/NetworkManager/conf.d/10-permanent-mac-address.conf ]; then

        sudo mkdir -pv /etc/NetworkManager/conf.d
        sudo cp -v "$HOME/Documents/linux_docs/configs/packages/network_manager/10-permanent-mac-address.conf" /etc/NetworkManager/conf.d/

        if command -v systemctl > /dev/null 2>&1; then
            sudo systemctl restart NetworkManager
        fi
        
    else
        echo "${green}Permanent MAC address is already enabled. ${reset}"
        exit 0
    fi
    
else
    echo "${yellow}Network Manager not detected. ${reset}"
fi

# Prints a conclusive message
echo "${green}Enabled: Permanent MAC address ${reset}"
