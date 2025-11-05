#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Checks for package manager
if command -v pacman > /dev/null 2>&1; then
    
    # Checks for yay
    if ! command -v yay > /dev/null 2>&1; then
        sudo pacman -S --needed --noconfirm git makepkg
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
        
    else
        echo "${green}yay is already installed. ${reset}"
        exit 1
    fi
    
else
    echo "${red}Unsupported package manager. ${reset}"
    exit 1
fi

# Prints a conclusive message
echo "${green}yay is now installed. ${reset}"

