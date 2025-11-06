#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Define primary package manager
if command -v apt > /dev/null 2>&1; then
    primary_package_manager="apt"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v dnf > /dev/null 2>&1; then
    primary_package_manager="dnf"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"

elif command -v eopkg > /dev/null 2>&1; then
    primary_package_manager="eopkg"
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

# Define AUR package manager
if command -v paru > /dev/null 2>&1; then
    aur_package_manager="paru"
    echo "Detected Package Manger: $aur_package_manager"

elif command -v yay > /dev/null 2>&1; then
    aur_package_manager="yay"
    echo "Detected Package Manger: $aur_package_manager"
    
else
    aur_package_manager="unknown"
fi

# Define init system
if ps -p 1 -o comm= | grep -Fq "systemd"; then
    init_system="systemd"
    echo "${green}Detected Init System: $init_system ${reset}"

elif ps -p 1 -o comm= | grep -Fq "runit"; then
    init_system="runit"
    echo "${green}Detected Init System: $init_system ${reset}"

elif ps -p 1 -o comm= | grep -Fq "sysvinit"; then
    init_system="sysvinit"
    echo "${green}Detected Init System: $init_system ${reset}"

elif ps -p 1 -o comm= | grep -Fq "openrc-init"; then
    init_system="openrc-init"
    echo "${green}Detected Init System: $init_system ${reset}"

else
    init_system="unknown"
fi

# List of packages
packages=("waydroid")
aur_packages=("waydroid")

# Checks for package manager and installs package(s)
if [ "$primary_package_manager" = "apt" ]; then
    sudo apt-get install -y curl ca-certificates
    
    # Adds repo(s)
    curl -s https://repo.waydro.id | sudo bash
    sudo apt-get install -y "${packages[@]}"

elif [ "$primary_package_manager" = "dnf" ]; then
    sudo dnf install -y "${packages[@]}"
    
    # Prints information required for Waydroid setup
    echo "System OTA: https://ota.waydro.id/system"
    echo "Vendor OTA: https://ota.waydro.id/vendor"

elif [ "$primary_package_manager" = "eopkg" ]; then
    sudo eopkg install -y "${packages[@]}"

elif [ "$primary_package_manager" = "pacman" ]; then

    # Checks for AUR package manager
    if [ "$aur_package_manager" != "unknown" ]; then
        "$aur_package_manager" -S "${aur_packages[@]}"
    else
        sudo pacman -S --needed --noconfirm base-devel git makepkg
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si --noconfirm
        cd ..
        rm -rf paru
        paru -S "${aur_packages[@]}"
    fi

elif [ "$primary_package_manager" = "xbps" ]; then
    sudo xbps-install -Sy "${packages[@]}" python3-pyclip wl-clipboard

elif [ "$primary_package_manager" = "rpm-ostree" ]; then

    if ! command -v waydroid > /dev/null 2>&1; then

        sudo rpm-ostree install "${packages[@]}"
        echo "${yellow}Reboot and run script again to complete. ${reset}"
        exit 0

    fi
    
else
    echo "${red}Unsupported package manager. ${reset}"
    exit 1
fi

# Initializes Waydroid
sudo waydroid init

# Checks init system and enables Waydroid container
if [ "$init_system" = "systemd" ]; then
    sudo systemctl enable --now waydroid-container

elif [ "$init_system" = "runit" ]; then
    sudo ln -s /etc/sv/waydroid-container /var/service
fi

# Prints a conclusive message
echo "${green}Waydroid is now installed. ${reset}"

