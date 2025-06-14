#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm ttf-ubuntu-font-family
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    echo "Manual installation required"
    echo "Go to https://design.ubuntu.com/font/"
    read -p "Press enter to exit"
    exit 1
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    echo "Manual installation required"
    echo "Go to https://design.ubuntu.com/font/"
    read -p "Press enter to exit"
    exit 1
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper ref && sudo zypper dup -y && sudo zypper in -y ubuntu-fonts
elif command -v xbps-install &> /dev/null; then
    echo "Detected: xbps"
    echo "Manual installation required"
    echo "Go to https://design.ubuntu.com/font/"
    read -p "Press enter to exit"
    exit 1
else
    echo "Unknown package manager."
    echo "Manual installation required"
    echo "Go to https://design.ubuntu.com/font/"
    read -p "Press enter to exit"
    exit 1
fi

# Prints a conclusive message
echo "Ubuntu fonts is now installed"
read -p "Press enter to exit"
