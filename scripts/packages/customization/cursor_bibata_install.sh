#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm bibata-cursor-theme
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y bibata-cursor-theme
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Adds repo(s)
    sudo dnf config-manager --add-repo https://terra.fyralabs.com/terra.repo

    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y bibata-cursor-theme
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    echo "Manual installation required. Go to https://github.com/ful1e5/Bibata_Cursor/"
    exit 1
else
    echo "Unknown package manager"
    echo "Manual installation required. Go to https://github.com/ful1e5/Bibata_Cursor/"
    exit 1
fi

# Prints a conclusive message to end the script
echo "Bibata Modern Ice cursor is now installed."
