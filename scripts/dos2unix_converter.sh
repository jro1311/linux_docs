#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for package
if ! command -v dos2unix > /dev/null 2>&1; then
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

    # Checks for package manager and installs package(s)
    if [ "$main_package_manager" = "apt" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo apt-get install -y dos2unix
        
    elif [ "$main_package_manager" = "dnf" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo dnf install -y dos2unix
        
    elif [ "$main_package_manager" = "pacman" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo pacman -S --needed --noconfirm dos2unix
        
    elif [ "$main_package_manager" = "xbps" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo xbps-install -Sy dos2unix
        
    elif [ "$main_package_manager" = "zypper" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo zypper in -y dos2unix
        
    elif [ "$main_package_manager" = "rpm-ostree" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo rpm-ostree install dos2unix
        echo "${yellow}Reboot to use package${reset}"
        exit 0
        
    else
        echo "${red}Unsupported package manager${reset}"
        exit 1
    fi
fi

# Prompts the user for input
read -er -p "Enter the path of the target directory (default is $HOME/Documents/): " target_dir
    
# Use default if no input is given
target_dir=${target_dir:-$HOME/Documents/}

# Expand ~ or $HOME to the full path
target_dir="${target_dir/#~/$HOME}"
target_dir="${target_dir/#\$HOME/$HOME}"

# Checks for directory
if [ ! -d "$target_dir" ]; then
    echo "$target_dir does not exist"
    exit 1
fi

# Prints target directory
echo "Target: $target_dir"
    
# Recursively finds all .md, .txt, and .sh files and converts them to unix format
for ext in md txt sh; do
    find "$target_dir" -type f \
        -name "*.$ext" \
        -exec dos2unix {} +
done

# Prints a conclusive message
echo "${green}Conversion complete ${reset}"
