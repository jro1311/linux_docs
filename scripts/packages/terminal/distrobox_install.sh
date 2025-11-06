#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

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

# List of packages
packages=("distrobox" "podman")

# Checks for package manager and installs package(s)
if [ "$primary_package_manager" = "apt" ]; then
    sudo apt-get install -y "${packages[@]}"
    
elif [ "$primary_package_manager" = "dnf" ]; then
    sudo dnf install -y "${packages[@]}"

elif [ "$primary_package_manager" = "eopkg" ]; then
    sudo eopkg install -y "${packages[@]}"
    
elif [ "$primary_package_manager" = "pacman" ]; then
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
elif [ "$primary_package_manager" = "xbps" ]; then
    echo "${yellow}No package available. ${reset}"
    exit 0
    #sudo xbps-install -Sy "${packages[@]}"
    
elif [ "$primary_package_manager" = "zypper" ]; then
    sudo zypper in -y "${packages[@]}"
    
elif [ "$primary_package_manager" = "rpm-ostree" ]; then

    if ! command -v "${packages[@]}" > /dev/null 2>&1; then
        sudo rpm-ostree install "${packages[@]}"
        echo "${yellow}Reboot and run script again to complete. ${reset}"
        exit 0
    fi
    
else
    echo "${red}Unsupported package manager. ${reset}"
    exit 1
fi

# Prompts the user for input
read -r -p "Enter an image to install [options: arch/debian/fedora/opensuse/ubuntu/void]: " image

# Convert image to lowercase
image=$(echo "$image" | tr '[:upper:]' '[:lower:]')

# Prints selected image
echo "${green}Selected Image: $image ${reset}"

# Creates distrobox instance
case "$image" in
    "arch")
        distrobox create -i quay.io/toolbx/arch-toolbox:latest
        ;;
    "debian")
        distrobox create -i quay.io/toolbx-images/debian-toolbox:latest
        ;;
    "fedora")
        distrobox create -i quay.io/fedora/fedora:rawhide
        ;;
    "opensuse")
        distrobox create -i registry.opensuse.org/opensuse/distrobox:latest
        ;;
    "ubuntu")
        distrobox create -i quay.io/toolbx/ubuntu-toolbox:latest
        ;;
    "void")
        distrobox create -i ghcr.io/void-linux/void-glibc-full:latest
        ;;
    *)
        echo "${red}Unsupported image. ${reset}"
        exit 1
        ;;
esac

# Prints a conclusive message
echo "${green}Distrobox is now installed. ${reset}"

