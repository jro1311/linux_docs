#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Checks for init system
if ps -p 1 -o comm= | grep -q "systemd"; then
    echo "${green}Detected Init System: systemd ${reset}"
else
    echo "${red}Unsupported init system ${reset}"
    exit 1
fi

# Define the operating system and convert it to lowercase
if [ -f /etc/os-release ]; then
    . /etc/os-release
    
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
    
    os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
    os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')
    
    echo "${green}Detected Distro (ID): $os ${reset}"
    echo "${green}Detected Distro (ID_LIKE): $os_like ${reset}"
    
else
    echo "${red}Unable to detect the operating system ${reset}"
    exit 1
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

# List of packages
packages=("snapd")
aur_packages=("snapd")

# Checks for package manager and installs package(s)
if [ "$primary_package_manager" = "apt" ]; then
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    sudo apt-get install -y "${packages[@]}"
    sudo snap install snapd
    
elif [ "$primary_package_manager" = "dnf" ]; then
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    sudo dnf install -y "${packages[@]}"
    
elif [ "$primary_package_manager" = "pacman" ]; then
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"   
    
    # Checks for AUR package manager
    if [ "$aur_package_manager" != "unknown" ]; then
        echo "${green}Detected Package Manager: $aur_package_manager ${reset}"
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
    
elif [ "$primary_package_manager" = "zypper" ]; then
    if [ "$os" = "opensuse-tumbleweed" ] || [ "$os" = "opensuse-slowroll" ]; then
    
        # Adds repo(s)
        sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Tumbleweed snappy
        sudo zypper --gpg-auto-import-keys refresh
        
        sudo zypper in -y "${packages[@]}"
        
    elif [ "$os" = "opensuse-leap" ]; then
    
        # Adds repo(s)
        sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Leap_16.0 snappy
        sudo zypper --gpg-auto-import-keys refresh
        
        sudo zypper in -y "${packages[@]}"
        
    else
        echo "${red}Unsupported operating system ${reset}"
        exit 1
    fi
    
elif [ "$primary_package_manager" = "rpm-ostree" ]; then
    sudo rpm-ostree install "${packages[@]}"
    echo "${green}Reboot to use package ${reset}"
    exit 0
    
else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Enables snapd
sudo systemctl enable --now snapd

# Enables classic snap support
sudo ln -s /var/lib/snapd/snap /snap

# Installs package(s)
sudo snap install snap-store

# Prints a conclusive message
echo "${green}Snap is now installed ${reset}"
echo "${green}Reboot or relogin to ensure Snap's paths are updated correctly ${reset}"

