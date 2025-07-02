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

# Detects the operating system and stores it in a variable
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
else
    echo "Unable to detect the operating system"
    read -p "Press enter to exit"
    exit 1
fi

# Converts the variable into lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

# Prints the detected operating system
echo "Detected (ID): $os"
echo "Detected (ID_LIKE): $os_like"

# Installs package(s) based on the package manager detected
if command -v apt > /dev/null 2>&1; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y btrfsmaintenance
elif command -v dnf > /dev/null 2>&1; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y btrfsmaintenance
elif command -v pacman > /dev/null 2>&1; then
    echo "Detected: pacman"
    # Checks for AUR helper
    if command -v paru > /dev/null 2>&1; then
        echo "Detected: paru"
        # Installs package(s)
        paru -Syu btrfsmaintenance
    elif command -v yay > /dev/null 2>&1; then
        echo "Detected: yay"
        # Installs package(s)
        yay -Syu btrfsmaintenance
    else
        # Installs package(s)
        sudo pacman -Syu --needed --noconfirm base-devel git makepkg
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
        
        # Installs package(s)
        yay -Syu btrfsmaintenance
    fi
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "Detected: rpm-ostree"
    # Installs package(s)
    sudo rpm-ostree upgrade && sudo rpm-ostree install btrfsmaintenance
    echo "Reboot to use package"
    read -p "Press enter to exit"
    exit 0
elif command -v xbps-install > /dev/null 2>&1; then
    echo "Detected: xbps"
    echo "No package available"
    read -p "Press enter to exit"
    exit 1
elif command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    # Installs package(s)
    if [ "$os" = "opensuse-tumbleweed" ] || [ "$os" = "opensuse-slowroll" ]; then
        sudo zypper ref && sudo zypper dup -y && sudo zypper in -y btrfsmaintenance
    elif [ "$os" = "opensuse-leap" ]; then
        sudo zypper ref && sudo zypper up -y && sudo zypper in -y btrfsmaintenance
    else
        echo "Unsupported operating system"
        read -p "Press enter to exit"
        exit 1
    fi
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

