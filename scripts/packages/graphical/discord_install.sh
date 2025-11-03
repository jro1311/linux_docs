#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Define primary package manager
if command -v apt > /dev/null 2>&1; then
    primary_package_manager="apt"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v dnf > /dev/null 2>&1; then
    primary_package_manager="dnf"
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

# Checks for flatpak and flathub
if ! command -v flatpak > /dev/null 2>&1 || ! flatpak remote-list | grep -q "flathub"; then
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
fi

# Define secondary package manager
if command -v flatpak > /dev/null 2>&1; then
    secondary_package_manager="flatpak"
    echo "${green}Detected Package Manager: $secondary_package_manager ${reset}"
    
elif command -v snap > /dev/null 2>&1; then
    secondary_package_manager="snap"
    echo "${green}Detected Package Manager: $secondary_package_manager ${reset}"
    
else
    secondary_package_manager="unknown"
fi

# List of packages
packages=("discord")
flatpaks=("com.discordapp.Discord")

# Checks for package manager
if [ "$primary_package_manager" = "apt" ]; then
    wget -O "$HOME/Downloads/discord.deb" "https://discord.com/api/download?platform=linux&format=deb"
    sudo apt-get install -y "$HOME/Downloads/discord.deb"
    rm -v "$HOME/Downloads/discord.deb"

elif [ "$primary_package_manager" = "dnf" ]; then
    sudo dnf install -y "${packages[@]}"

elif [ "$primary_package_manager" = "pacman" ]; then
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
elif [ "$primary_package_manager" = "xbps" ]; then
    flatpak install flathub -y "${flatpaks[@]}"

elif [ "$primary_package_manager" = "zypper" ]; then
    sudo zypper in -y "${packages[@]}"
    
elif [ "$secondary_package_manager" = "flatpak" ]; then
    flatpak install flathub -y "${flatpaks[@]}"

elif [ "$secondary_package_manager" = "snap" ]; then
    sudo snap install "${packages[@]}"
    
elif [ "$primary_package_manager" = "rpm-ostree" ]; then
    sudo rpm-ostree install "${packages[@]}"
    
else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Prints a conclusive message
echo "${green}Discord is now installed. ${reset}"

