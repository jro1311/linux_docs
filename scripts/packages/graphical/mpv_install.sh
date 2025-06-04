#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm mpv
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y mpv
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y mpv
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper ref && sudo zypper -y dup && sudo zypper in -y mpv
else
    echo "Unknown package manager"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y app/io.mpv.Mpv/x86_64/stable
fi

# Makes directory(s)
mkdir -pv "$HOME"/.config/mpv
mkdir -pv "$HOME"/.var/app/io.mpv.Mpv/config/mpv

# Function to check for battery presence
check_battery() {
    if [ -d /sys/class/power_supply/BAT0 ] || [ -d /sys/class/power_supply/BAT1 ]; then
        return 0  # Battery detected
    else
        return 1  # No battery detected
    fi
}

# Check for battery
if check_battery; then
    echo "Battery detected"
    # Copies config(s)
    cp -vr "$HOME"/Documents/linux_docs/configs/packages/mpv_laptop "$HOME"/.config/
    cp -vr "$HOME"/Documents/linux_docs/configs/packages/mpv_laptop "$HOME"/.var/app/io.mpv.Mpv/config/
    
    # Changes name(s)
    mv -v "$HOME"/.config/mpv_laptop "$HOME"/.config/mpv
    mv -v "$HOME"/.var/app/io.mpv.Mpv/config/mpv_laptop "$HOME"/.var/app/io.mpv.Mpv/config/mpv
    
else
    echo "No battery detected"
    # Copies config(s)
    cp -vr "$HOME"/Documents/linux_docs/configs/packages/mpv "$HOME"/.config/
    cp -vr "$HOME"/Documents/linux_docs/configs/packages/mpv "$HOME"/.var/app/io.mpv.Mpv/config/
fi

# Prints a conclusive message to end the script
echo "mpv is now installed."
