#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

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

if command -v snap > /dev/null 2>&1; then
    secondary_package_manager="snap"

else
    secondary_package_manager="unknown"
fi

# List of packages
packages=("btop")

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for main package manager and installs package(s)
if [ "$main_package_manager" = "apt" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo apt-get install -y "${packages[@]}"
    
    # Checks for AMD GPU
    if echo "$gpu_info" | grep -i "amd" > /dev/null 2>&1; then
        echo "Detected GPU: AMD"
        sudo apt-get install -y rocm-smi
    fi

elif [ "$main_package_manager" = "dnf" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo dnf install -y "${packages[@]}"
    
    # Checks for AMD GPU
    if echo "$gpu_info" | grep -i "amd" > /dev/null 2>&1; then
        echo "Detected GPU: AMD"
        sudo dnf install -y rocm-smi
    fi

elif [ "$main_package_manager" = "pacman" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
    # Checks for AMD GPU
    if echo "$gpu_info" | grep -i "amd" > /dev/null 2>&1; then
        echo "Detected GPU: AMD"
        sudo pacman -S --needed --noconfirm rocm-smi-lib
    fi
    
elif [ "$main_package_manager" = "xbps" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo xbps-install -Sy "${packages[@]}"
    
    # Checks for AMD GPU
    if echo "$gpu_info" | grep -i "amd" > /dev/null 2>&1; then
        echo "Detected GPU: AMD"
        sudo xbps-install -y ROCm-SMI
    fi

elif [ "$main_package_manager" = "zypper" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo zypper in -y "${packages[@]}"
    
elif [ "$secondary_package_manager" = "snap" ]; then
    echo "${green}Detected Package Manager: $secondary_package_manager ${reset}"
    sudo snap install "${packages[@]}"
    
elif [ "$main_package_manager" = "rpm-ostree" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo rpm-ostree install "${packages[@]}"
    
    # Checks for AMD GPU
    if echo "$gpu_info" | grep -i "amd" > /dev/null 2>&1; then
        echo "Detected GPU: AMD"
        sudo rpm-ostree install -y rocm-smi
    fi
    
else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/btop"
    
# Copies config(s)
cp -v "$HOME/Documents/linux_docs/configs/packages/btop.conf" "$HOME/.config/btop/"

# Prints a conclusive message
echo "${green}btop is now installed ${reset}"

