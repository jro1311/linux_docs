#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for package manager and installs package(s)
if command -v apt > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: apt ${reset}"
    sudo apt-get install -y dmz-cursor-theme

elif command -v dnf > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: dnf ${reset}"
    echo "${yellow}Manual installation required ${reset}"
    echo "${yellow}Go to https://github.com/rhizoome/dmz-cursors/ ${reset}"
    exit 0
    
elif command -v pacman > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: pacman ${reset}"
    if command -v paru > /dev/null 2>&1; then
        echo "${green}Detected Package Manager: paru ${reset}"
        paru -S xcursor-dmz
    elif command -v yay > /dev/null 2>&1; then
        echo "${green}Detected Package Manager: yay ${reset}"
        yay -S xcursor-dmz
    else
        sudo pacman -S --needed --noconfirm base-devel git makepkg
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si --noconfirm
        cd ..
        rm -rf paru
        paru -S xcursor-dmz
    fi
    
elif command -v xbps-install > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: xbps ${reset}"
    echo "${yellow}Manual installation required ${reset}"
    echo "${yellow}Go to https://github.com/rhizoome/dmz-cursors/ ${reset}"
    exit 0
    
elif command -v zypper > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: zypper ${reset}"
    sudo zypper in -y dmz-icon-theme-cursors
    
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: rpm-ostree ${reset}"
    echo "${yellow}Manual installation required ${reset}"
    echo "${yellow}Go to https://github.com/rhizoome/dmz-cursors/ ${reset}"
    exit 0

else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Prints a conclusive message
echo "${green}DMZ cursor is now installed ${reset}"
