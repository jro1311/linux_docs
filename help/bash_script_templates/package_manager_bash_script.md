#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for package
if ! command -v package-name &> /dev/null; then
    # Checks for package manager
    if command -v pacman &> /dev/null; then
        echo "Detected: pacman"
        # Installs package(s)
        sudo pacman -Syu --needed --noconfirm package-name
    elif command -v apt &> /dev/null; then
        echo "Detected: apt"
        # Installs package(s)
        sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y package-name
    elif command -v dnf &> /dev/null; then
        echo "Detected: dnf"
        # Installs package(s)
        sudo dnf upgrade -y && sudo dnf install -y package-name
    elif command -v zypper &> /dev/null; then
        echo "Detected: zypper"
        # Installs package(s)
        sudo zypper ref && sudo zypper -y dup && sudo zypper in -y package-name
    elif command -v xbps-install &> /dev/null; then
        echo "Detected: xbps"
        # Installs package(s)
        sudo xbps-install -u -y && sudo xbps-install -y
    else
        echo "Unsupported package manager"
        read -p "Press enter to exit"
        exit 1
    fi
fi

# Checks for package
if command -v flatpak &> /dev/null; then
    echo "Detected: flatpak"
    flatpak update -y && flatpak install flathub -y package-name
else
    echo "flatpak not detected"
fi

# Checks for package
if command -v snap &> /dev/null; then
    echo "Detected: snap"
    sudo snap install package-name
else
    echo "snap not detected"
fi

# Prints a conclusive message
echo "x is now installed"
read -p "Press enter to exit"
