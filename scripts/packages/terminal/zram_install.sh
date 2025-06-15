#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm zram-generator
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y systemd-zram-generator
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y zram-generator
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper ref && sudo zypper dup -y && sudo zypper in -y zram-generator
elif command -v xbps-install &> /dev/null; then
    echo "Detected: xbps"
    # Installs package(s)
    sudo xbps-install -Su xbps && sudo xbps-install -u && sudo xbps-install -y zramen
else
    echo "Unsupported package manager"
    read -p "Press enter to exit"
    exit 1
fi

# Copies config(s)
sudo cp -v "$HOME/Documents/linux_docs/configs/packages/99-zram.conf" /etc/sysctl.d/

# Enables nullglob so that the glob expands to nothing if no match
shopt -s nullglob

# Detects batteries and stores in a variable
batteries=(/sys/class/power_supply/BAT*)

# Checks for battery
if (( ${#batteries[@]} )); then
    echo "Detected System: Laptop"
    # Checks for init system
    if ps -p 1 -o comm= | grep -q "systemd"; then
        echo "Detected: systemd"
        # Copies config(s)
        sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram-generator_laptop.conf" /etc/systemd/
        
        # Changes name(s)
        sudo mv -v /etc/systemd/zram-generator_laptop.conf /etc/systemd/zram-generator.conf
        
        # Reloads systemd manager configuration
        sudo systemctl daemon-reload
        
        # Starts the zram device immediately
        sudo systemctl start /dev/zram0
    elif ps -p 1 -o comm= | grep -q "runit"; then
        echo "Detected: runit"
        # Makes zram swap device
        sudo zramen make -a lz4 -s 100
    fi
else
    echo "Detected System: Desktop"
    # Checks for init system
    if ps -p 1 -o comm= | grep -q "systemd"; then
        echo "Detected: systemd"
        # Copies config(s)
        sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram-generator.conf" /etc/systemd/
        
        # Reloads systemd manager configuration
        sudo systemctl daemon-reload
        
        # Starts the zram device immediately
        sudo systemctl start /dev/zram0
    elif ps -p 1 -o comm= | grep -q "runit"; then
        echo "Detected: runit"
        # Makes zram swap device
        sudo zramen make -a zstd -s 100
    fi
fi

# Loads and applies kernel parameter settings from the 99-zram.conf
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Prints a conclusive message
echo "zram is now installed"
read -p "Press enter to exit"
