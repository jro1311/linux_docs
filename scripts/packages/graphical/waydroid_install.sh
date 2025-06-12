#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for flatpak and flathub
if ! command -v flatpak &> /dev/null || ! flatpak remote-list | grep -q "flathub"; then
    # Runs script to install flatpak and set up flathub
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
fi

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Checks for paru
    if command -v paru > /dev/null 2>&1; then
        # Installs package(s)
        paru -Syu waydroid
    fi

    # Checks for yay
    if ! command -v yay > /dev/null 2>&1; then
        sudo pacman -Syu --needed --noconfirm base-devel git makepkg
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    else
        # Installs package(s)
        yay -Syu waydroid
    fi
        
    # Initializes container
    sudo waydroid init
        
    # Enables container
    sudo systemctl enable --now waydroid-container
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y curl ca-certificates
        
    # Adds repo(s)
    curl -s https://repo.waydro.id | sudo bash
        
    # Installs package(s)
    sudo apt-get install -y waydroid
        
    # Enables container
    sudo systemctl enable --now waydroid-container
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y waydroid
        
    # Enables container
    sudo systemctl enable --now waydroid-container
        
    # Prints setup information
    echo "System OTA: https://ota.waydro.id/system"
    echo "Vendor OTA: https://ota.waydro.id/vendor"
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    echo "Manual installation required"
    read -p "Press enter to exit"
    exit 1
else
    echo "Unknown package manager"
    read -p "Press enter to exit"
    exit 1
fi

# Prints a conclusive message
echo "Waydroid is now installed"
read -p "Press enter to exit"
