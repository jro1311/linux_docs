#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for btrfs partitions
if mount | grep -q "type btrfs"; then
    echo "Detected File System: btrfs"
else
    echo "No btrfs partitions detected"
    read -p "Press enter to exit"
    exit 1
fi

# Checks for init system
if ps -p 1 -o comm= | grep -q "systemd"; then
    echo "Detected: systemd"
else
    echo "Unsupported init system"
    read -p "Press enter to exit"
    exit 1
fi

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Checks for paru
    if command -v paru > /dev/null 2>&1; then
        # Installs package(s)
        paru -Syu btrfsmaintenance
    fi

    # Checks for yay
    if ! command -v yay > /dev/null 2>&1; then
        sudo pacman -Syu --needed --noconfirm base-devel git makepkg
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    else
        # Installs package(s)
        yay -Syu btrfsmaintenance
    fi
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y btrfsmaintenance
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y btrfsmaintenance
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper ref && sudo zypper dup -y && sudo zypper in -y btrfsmaintenance
else
    echo "Unsupported package manager"
    read -p "Press enter to exit"
    exit 1
fi

# Configures system timer(s)
sudo systemctl disable btrfs-defrag.timer
sudo systemctl disable btrfs-trim.timer
sudo systemctl enable btrfs-balance.timer
sudo systemctl enable btrfs-scrub.timer
sudo systemctl enable btrfsmaintenance-refresh.path

# Prints a conclusive message
echo "btrfsmaintenance is now installed"
read -p "Press enter to exit"

