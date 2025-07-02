#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

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
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y systemd-zram-generator
elif command -v dnf > /dev/null 2>&1; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y zram-generator
elif command -v pacman > /dev/null 2>&1; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm zram-generator
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "Detected: rpm-ostree"
    # Installs package(s)
    sudo rpm-ostree upgrade && sudo rpm-ostree install zram-generator
elif command -v xbps-install > /dev/null 2>&1; then
    echo "Detected: xbps"
    # Installs package(s)
    sudo xbps-install -Suy xbps && sudo xbps-install -uy && sudo xbps-install -y zramen
elif command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    # Installs package(s)
    if [ "$os" = "opensuse-tumbleweed" ] || [ "$os" = "opensuse-slowroll" ]; then
        sudo zypper ref && sudo zypper dup -y && sudo zypper in -y zram-generator
    elif [ "$os" = "opensuse-leap" ]; then
        sudo zypper ref && sudo zypper up -y && sudo zypper in -y zram-generator
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

# Makes directory(s)
sudo mkdir -pv /etc/sysctl.d

# Loads and applies kernel parameter settings
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Prints a conclusive message
echo "zram is now installed"
read -p "Press enter to exit"
