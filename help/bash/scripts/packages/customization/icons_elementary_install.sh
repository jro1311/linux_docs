#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Detect the operating system
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
else
    echo "${red}Unable to detect the operating system ${reset}"
    exit 1
fi

# Convert operating system to lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

# Checks for package manager and installs package(s)
if command -v apt > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: apt ${reset}"
    sudo apt-get install -y elementary-icon-theme
    
elif command -v dnf > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: dnf ${reset}"
    sudo dnf install -y elementary-icon-theme
    
elif command -v pacman > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: pacman ${reset}"
    sudo pacman -S --needed --noconfirm elementary-icon-theme
    
elif command -v xbps-install > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: xbps ${reset}"
    echo "${yellow}Manual installation required ${reset}"
    echo "${yellow}Go to https://github.com/shimmerproject/elementary-xfce/ ${reset}"
    exit 0
    
elif command -v zypper > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: zypper ${reset}"
    sudo zypper in -y pantheon-icons
    
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: rpm-ostree ${reset}"
    sudo rpm-ostree install elementary-icon-theme
    
else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Prints a conclusive message
echo "${green}Elementary icons are now installed${reset}"

