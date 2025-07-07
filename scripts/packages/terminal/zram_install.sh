#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Detect init system
if ps -p 1 -o comm= | grep -q "systemd"; then
    init_system="systemd"
    
elif ps -p 1 -o comm= | grep -q "runit"; then
    init_system="runit"
    
else
    init_system="unknown"
fi

# Detect main package manager
if command -v apt > /dev/null 2>&1; then
    main_package_manager="apt"
     
elif command -v dnf > /dev/null 2>&1; then
    main_package_manager="dnf"
    
elif command -v pacman > /dev/null 2>&1; then
    main_package_manager="pacman"
    
elif command -v xbps-install > /dev/null 2>&1; then
    main_package_manager="xbps"
    
elif command -v zypper > /dev/null 2>&1; then
    main_package_manager="zypper"

elif command -v rpm-ostree > /dev/null 2>&1; then
    main_package_manager="rpm-ostree"

else
    main_package_manager="unknown"
fi

# List of packages
packages=("zram-generator")

# Checks for main package manager and installs package(s)
if [ "$main_package_manager" = "apt" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo apt-get install -y systemd-zram-generator
    
elif [ "$main_package_manager" = "dnf" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo dnf install -y "${packages[@]}"
    
elif [ "$main_package_manager" = "pacman" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
elif [ "$main_package_manager" = "xbps" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo xbps-install -Sy zramen
    
elif [ "$main_package_manager" = "zypper" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo zypper in -y "${packages[@]}"
    
elif [ "$main_package_manager" = "rpm-ostree" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo rpm-ostree install "${packages[@]}"
    
else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Copies config(s)
sudo cp -v "$HOME/Documents/linux_docs/configs/packages/99-zram.conf" /etc/sysctl.d/

# Enables nullglob so that the glob expands to nothing if no match
shopt -s nullglob

# Detect batteries
batteries=(/sys/class/power_supply/BAT*)

# Checks for battery
if (( ${#batteries[@]} )); then
    echo "${green}Detected System: Laptop ${reset}"
    # Checks for init system
    if [ "$init_system" = "systemd" ]; then
        echo "${green}Detected Init System: $init_system ${reset}"
        # Copies config(s)
        sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram-generator_laptop.conf" /etc/systemd/
        
        # Changes name(s)
        sudo mv -v /etc/systemd/zram-generator_laptop.conf /etc/systemd/zram-generator.conf
        
        # Reloads systemd manager configuration
        sudo systemctl daemon-reload
        
        # Starts the zram device immediately
        sudo systemctl start /dev/zram0
        
    elif [ "$init_system" = "runit" ]; then
        echo "Detected: runit"
        # Makes zram swap device
        sudo zramen make -a lz4 -s 100
    fi
else
    echo "${green}Detected System: Desktop ${reset}"
    # Checks for init system
    if [ "$init_system" = "systemd" ]; then
        echo "${green}Detected Init System: $init_system ${reset}"
        # Copies config(s)
        sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram-generator.conf" /etc/systemd/
        
        # Reloads systemd manager configuration
        sudo systemctl daemon-reload
        
        # Starts the zram device immediately
        sudo systemctl start /dev/zram0
        
    elif [ "$init_system" = "runit" ]; then
        echo "${green}Detected Init System: $init_system ${reset}"
        # Makes zram swap device
        sudo zramen make -a zstd -s 100
    fi
fi

# Makes directory(s)
sudo mkdir -pv /etc/sysctl.d

# Loads and applies kernel parameter settings
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Prints a conclusive message
echo "${green}zRAM is now installed ${reset}"
