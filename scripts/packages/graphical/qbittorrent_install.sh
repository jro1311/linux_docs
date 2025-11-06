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

# Makes directory(s)
mkdir -pv "$HOME/.config/autostart"

# List of packages
packages=("qbittorrent")
flatpaks=("qbittorrent")
snaps=("qbittorrent-arnatious")

# Checks for package manager and installs package(s)
if [ "$primary_package_manager" = "apt" ]; then
    sudo apt-get install -y "${packages[@]}"

elif [ "$primary_package_manager" = "dnf" ]; then
    sudo dnf install -y "${packages[@]}"

elif [ "$primary_package_manager" = "eopkg" ]; then
    sudo eopkg install -y "${packages[@]}"

elif [ "$primary_package_manager" = "pacman" ]; then
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
elif [ "$primary_package_manager" = "xbps" ]; then
    sudo xbps-install -Sy "${packages[@]}"

elif [ "$primary_package_manager" = "zypper" ]; then
    sudo zypper in -y "${packages[@]}"
    
elif [ "$secondary_package_manager" = "flatpak" ]; then
    flatpak install flathub -y "${flatpaks[@]}"
    
    # Adds package(s) to autostart
    cp -v /var/lib/flatpak/exports/share/applications/org.qbittorrent.qBittorrent.desktop "$HOME/.config/autostart/"
    
    # Prints a conclusive message
    echo "${green}qBittorrent is now installed. ${reset}"
    exit 0

elif [ "$secondary_package_manager" = "snap" ]; then
    sudo snap install "${snaps[@]}"
    
    # Adds package(s) to autostart
    cp -v /var/lib/snap/exports/share/applications/qbittorrent-arnatious.desktop "$HOME/.config/autostart/"
    
    # Prints a conclusive message
    echo "${green}qBittorrent is now installed. ${reset}"
    exit 0
    
elif [ "$primary_package_manager" = "rpm-ostree" ]; then
    sudo rpm-ostree install "${packages[@]}"
    
    # Prints a conclusive message
    echo "${green}qBittorrent is now installed. ${reset}"
    exit 0
    
else
    echo "${red}Unsupported package manager. ${reset}"
    exit 1
fi

# Adds package(s) to autostart
cp -v /usr/share/applications/org.qbittorrent.qBittorrent.desktop "$HOME/.config/autostart/"

# Prints a conclusive message
echo "${green}qBittorrent is now installed. ${reset}"



