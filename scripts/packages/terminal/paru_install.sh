#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Checks for package manager
if command -v pacman > /dev/null 2>&1; then
    
    # Checks for paru
    if ! command -v paru > /dev/null 2>&1; then
        sudo pacman -S --needed --noconfirm base-devel git
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si --noconfirm
        cd ..
        rm -rf paru
        
    else
        echo "${green}paru is already installed. ${reset}"
        exit 1
    fi
    
else
    echo "${red}Unsupported package manager. ${reset}"
    exit 1
fi

# Prints a conclusive message
echo "${green}paru is now installed. ${reset}"

