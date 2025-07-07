#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Detect the operating system
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
else
    echo "${red}Unable to detect the operating system ${reset}"
    exit 1
fi

# Convert operating system to lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

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
packages=("distrobox" "podman")

# Checks for main package manager and installs package(s)
if [ "$main_package_manager" = "apt" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo apt-get install -y "${packages[@]}"
    
elif [ "$main_package_manager" = "dnf" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo dnf install -y "${packages[@]}"
    
elif [ "$main_package_manager" = "pacman" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
elif [ "$main_package_manager" = "xbps" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo xbps-install -Sy "${packages[@]}"
    
elif [ "$main_package_manager" = "zypper" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo zypper in -y "${packages[@]}"
    
elif [ "$main_package_manager" = "rpm-ostree" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo rpm-ostree install "${packages[@]}"
    echo "${yellow}Reboot to use package ${reset}"
    exit 0
    
else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Prompts the user for input
read -r -p "Enter a container image to install (arch/debian/fedora/opensuse/ubuntu): " image

# Convert image to lowercase
image=$(echo "$image" | tr '[:upper:]' '[:lower:]')

# Prints selected image
echo "Selected Image: $image"

# Creates distrobox instance
if [ "$image" = "arch" ]; then
    distrobox create -i quay.io/toolbx/arch-toolbox:latest
    
elif [ "$image" = "debian" ]; then
    distrobox create -i quay.io/toolbx-images/debian-toolbox:latest
    
elif [ "$image" = "fedora" ]; then
    distrobox create -i quay.io/fedora/fedora:rawhide
    
elif [ "$image" = "opensuse" ]; then
    distrobox create -i registry.opensuse.org/opensuse/distrobox:latest
    
elif [ "$image" = "ubuntu" ]; then
    distrobox create -i quay.io/toolbx/ubuntu-toolbox:latest
    
else
    echo "${red}Unsupported image${reset}"
    exit 1
fi

# Prints a conclusive message
echo "${green}Distrobox is now installed ${reset}"

