#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm mangohud lib32-mangohud
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y mangohud
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y mangohud
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper ref && sudo zypper -y dup && sudo zypper in -y mangohud mangohud-32bit
else
    echo "Unknown package manager"
    exit 1
fi

# Runs script to install flatpak
chmod +x "$HOME"/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh
"$HOME"/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh

# Installs package(s)
flatpak update -y && flatpak install -y runtime/org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/24.08

# Makes directory(s)
mkdir -pv "$HOME"/.config/MangoHud
mkdir -pv "$HOME"/Documents/mangohud/logs

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
        cp -v "$HOME"/Documents/linux_docs/configs/packages/MangoHud_laptop.conf "$HOME"/.config/MangoHud/
        
        # Changes name(s)
        mv -v "$HOME"/.config/MangoHud/MangoHud_laptop.conf "$HOME"/.config/MangoHud/MangoHud.conf
else
    echo "No battery detected"
        # Copies config(s) to the system
        cp -v "$HOME"/Documents/linux_docs/configs/packages/MangoHud.conf "$HOME"/.config/MangoHud/
fi

# Prints a conclusive message to end the script
echo "MangoHud is now installed."
