#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Define init system
if ps -p 1 -o comm= | grep -q "systemd"; then
    init_system="systemd"
    echo "${green}Detected Init System: $init_system ${reset}"
    
elif ps -p 1 -o comm= | grep -q "runit"; then
    init_system="runit"
    echo "${green}Detected Init System: $init_system ${reset}"
    
else
    init_system="unknown"
fi

# Define primary package manager
if command -v apt > /dev/null 2>&1; then
    primary_package_manager="apt"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v dnf > /dev/null 2>&1; then
    primary_package_manager="dnf"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v pacman > /dev/null 2>&1; then
    primary_package_manager="pacman"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v xbps-install > /dev/null 2>&1; then
    primary_package_manager="xbps"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v zypper > /dev/null 2>&1; then
    primary_package_manager="zypper"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v rpm-ostree > /dev/null 2>&1; then
    primary_package_manager="rpm-ostree"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
else
    primary_package_manager="unknown"
fi

# List of packages
packages=("zram-generator")

# Checks for package manager and installs package(s)
if [ "$primary_package_manager" = "apt" ]; then
    sudo apt-get install -y systemd-zram-generator
    
elif [ "$primary_package_manager" = "dnf" ]; then
    sudo dnf install -y "${packages[@]}"
    
elif [ "$primary_package_manager" = "pacman" ]; then
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
elif [ "$primary_package_manager" = "xbps" ]; then
    sudo xbps-install -Sy zramen
    
elif [ "$primary_package_manager" = "zypper" ]; then
    sudo zypper in -y "${packages[@]}"
    
elif [ "$primary_package_manager" = "rpm-ostree" ]; then
    sudo rpm-ostree install "${packages[@]}"
    
else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Makes directory(s)
sudo mkdir -pv /etc/sysctl.d

# Copies config(s)
sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram/99-zram.conf" /etc/sysctl.d/

# Enables nullglob so that the glob expands to nothing if no match
shopt -s nullglob

# Detect batteries
batteries=(/sys/class/power_supply/BAT*)

# Checks for battery
if (( ${#batteries[@]} )); then
    echo "${green}Detected System: Laptop ${reset}"
    
    # Checks for init system
    if [ "$init_system" = "systemd" ]; then
    
        # Copies config(s)
        sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram/zram-generator.conf" /etc/systemd/
        
        # Edits compression algorithm from zstd to lz4
        sudo sed -i 's/zstd/lz4/g' /etc/systemd/zram-generator.conf
        
        # Reloads systemd manager configuration
        sudo systemctl daemon-reload
        
        # Starts the zram device immediately
        sudo systemctl start /dev/zram0
        
    elif [ "$init_system" = "runit" ]; then
    
        # Removes old zram swap devices if present
        if zramctl /dev/zram* > /dev/null 2>&1; then
            sudo zramen toss
        fi
    
        # Makes zram swap device
        sudo zramen make -a lz4 -s 100
        
        # Adds command to boot sequence
        if ! grep -Fq "zramen" /etc/rc.local; then
            echo "zramen make -a lz4 -s 100" | sudo tee -a /etc/rc.local
        fi
    fi
else
    echo "${green}Detected System: Desktop ${reset}"
    
    # Checks for init system
    if [ "$init_system" = "systemd" ]; then
    
        # Copies config(s)
        sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram/zram-generator.conf" /etc/systemd/
        
        # Reloads systemd manager configuration
        sudo systemctl daemon-reload
        
        # Starts the zram device immediately
        sudo systemctl start /dev/zram0
        
    elif [ "$init_system" = "runit" ]; then
    
        # Removes old zram swap devices if present
        if zramctl /dev/zram* > /dev/null 2>&1; then
            sudo zramen toss
        fi
    
        # Makes zram swap device
        sudo zramen make -a zstd -s 100
        
        # Adds command to boot sequence
        if ! grep -Fq "zramen" /etc/rc.local; then
            echo "zramen make -a zstd -s 100" | sudo tee -a /etc/rc.local
        fi
    fi
fi

# Loads and applies kernel parameter settings
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Prints a conclusive message
echo "${green}zram is now installed ${reset}"
