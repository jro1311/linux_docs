#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for package
if ! command -v git > /dev/null 2>&1; then
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
        sudo apt-get install -y git
        
    elif [ "$main_package_manager" = "dnf" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo dnf install -y git
        
    elif [ "$main_package_manager" = "pacman" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo pacman -S --needed --noconfirm git
        
    elif [ "$main_package_manager" = "xbps" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo xbps-install -Sy git
        
    elif [ "$main_package_manager" = "zypper" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo zypper in -y git
        
    elif [ "$main_package_manager" = "rpm-ostree" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo rpm-ostree install git
        echo "${yellow}Reboot to use package${reset}"
        exit 0
        
    else
        echo "${red}Unsupported package manager${reset}"
        exit 1
    fi
fi

# Define the source and base directories
source_dir="$HOME/Documents/linux_docs"
base_dir="$HOME/Documents/linux_docs_old"

# Checks for directory
if [ -d "$base_dir" ]; then
    # Use numbered naming logic
    count=1
    new_dir="$base_dir"
    while [ -d "$new_dir" ]; do
        new_dir="$base_dir$count"
        count=$((count + 1))
    done
    # Renames directory(s)
    mv -v "$source_dir" "$new_dir"
else
    # Renames directory(s)
    mv -v "$source_dir" "$base_dir"
fi

# Clones git repository
git clone https://github.com/jro1311/linux_docs.git "$source_dir"

# Print a conclusive message
echo "${green}Git clone complete ${reset}"
