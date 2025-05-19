#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm htop
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt update && sudo apt upgrade -y && sudo apt install -y htop
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y htop
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper ref && sudo zypper -y dup && sudo zypper in -y htop
else
    echo "Unknown package manager"
    exit 1
fi

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
    # Makes directory(s)
    mkdir -pv $HOME/.config/htop 
    
    # Copies config(s)
    cp -v $HOME/Documents/linux_docs/configs/packages/htoprc_laptop $HOME/.config/htop/
    mv -v $HOME/.config/htop/htoprc_laptop $HOME/.config/htop/htoprc
else
    echo "No battery detected"
    # Makes directory(s)
    mkdir -pv $HOME/.config/htop
    
    # Copies config(s)
    cp -v $HOME/Documents/linux_docs/configs/packages/htoprc $HOME/.config/htop/
fi

# Prints a conclusive message to end the script
echo "htop is now installed."
