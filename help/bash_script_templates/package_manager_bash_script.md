#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for package
if ! command -v package-name &> /dev/null; then
    # Installs package(s) based on the package manager detected
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
    else
        echo "Unknown package manager"
        exit 1
    fi
fi

# Checks for package
if command -v flatpak &> /dev/null; then
    echo "flatpak detected"
    flatpak update -y && flatpak install flathub -y package-name
else
    echo "Flatpak not detected"
fi

# Checks for package
if command -v snap &> /dev/null; then
    echo "snap detected"
    sudo snap install package-name
else
    echo "snap not detected"
fi

# Prints a conclusive message
echo "x is now installed"
