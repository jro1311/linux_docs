#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm flatpak
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y flatpak
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y flatpak
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper ref && sudo zypper dup -y && sudo zypper in -y flatpak
else
    echo "Unknown package manager"
    read -p "Press enter to exit"
    exit 1
fi

# Checks for wheel group
if getent group wheel > /dev/null 2>&1; then
    # Adds current user to wheel group
    sudo usermod -aG wheel "$USER"
else
    echo "wheel group does not exist"
fi

# Adds Flathub repository if it doesn't already exist
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Prints a conclusive message
echo "Flatpak is now installed"
read -p "Press enter to exit"
