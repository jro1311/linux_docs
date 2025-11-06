#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Define the operating system and convert it to lowercase
if [ -f /etc/os-release ]; then
    . /etc/os-release
    
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
    
    os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
    os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')
    
    echo "${green}Detected Distro (ID): $os ${reset}"
    echo "${green}Detected Distro (ID_LIKE): $os_like ${reset}"
    
else
    echo "${red}Unable to detect the operating system. ${reset}"
    exit 1
fi

# Define primary package manager
if command -v apt > /dev/null 2>&1; then
    primary_package_manager="apt"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v dnf > /dev/null 2>&1; then
    primary_package_manager="dnf"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"

elif command -v eopkg > /dev/null 2>&1; then
    primary_package_manager="eopkg"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v pacman > /dev/null 2>&1; then
    primary_package_manager="pacman"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v xbps-install > /dev/null 2>&1; then
    primary_package_manager="xbps"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v zypper > /dev/null 2>&1; then
    primary_package_manager="zypper"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v rpm-ostree > /dev/null 2>&1; then
    primary_package_manager="rpm-ostree"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
else
    primary_package_manager="unknown"
fi

# Checks for package manager and installs package(s)
if [ "$primary_package_manager" = "apt" ]; then
    sudo apt-get install -y bibata-cursor-theme

elif [ "$primary_package_manager" = "dnf" ]; then

    if [ "$os" = "openmandriva" ]; then
        echo "${yellow}Manual installation required. ${reset}"
        echo "${yellow}Go to https://github.com/ful1e5/Bibata_Cursor/ ${reset}"
        exit 0

    else 
        sudo dnf config-manager --add-repo https://terra.fyralabs.com/terra.repo
        sudo dnf install -y bibata-cursor-theme
    fi

elif [ "$primary_package_manager" = "eopkg" ]; then
    sudo eopkg install -y bibata-cursors

elif [ "$primary_package_manager" = "pacman" ]; then
    sudo pacman -S --needed --noconfirm bibata-cursor-theme

else
    echo "${yellow}Manual installation required. ${reset}"
    echo "${yellow}Go to https://github.com/ful1e5/Bibata_Cursor/ ${reset}"
    exit 0
fi

# Prints a conclusive message
echo "${green}Bibata Cursor is now installed. ${reset}"

