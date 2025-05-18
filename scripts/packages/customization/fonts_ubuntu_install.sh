#!/bin/bash

# Ensures that scripts exit immediately when any error occurs, and it treats unset variables and pipeline failures as errors
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm ttf-ubuntu-font-family
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    echo "Manual installation required. Go to https://design.ubuntu.com/font"
    exit 1
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    echo "Manual installation required. Go to https://design.ubuntu.com/font"
    exit 1
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper ref && sudo zypper -y dup && sudo zypper in -y ubuntu-fonts
else
    echo "Unknown package manager"
    echo "Manual installation required. Go to https://design.ubuntu.com/font"
    exit 1
fi

# Prints a conclusive message to end the script
echo "Ubuntu fonts is now installed."
