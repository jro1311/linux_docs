#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for package
if ! command -v git > /dev/null 2>&1; then

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
    packages=("git")

    # Checks for package manager and installs package(s)
    if [ "$primary_package_manager" = "apt" ]; then
        sudo apt-get install -y "${packages[@]}"
        
    elif [ "$primary_package_manager" = "dnf" ]; then
        sudo dnf install -y "${packages[@]}"
        
    elif [ "$primary_package_manager" = "pacman" ]; then
        sudo pacman -S --needed --noconfirm "${packages[@]}"
        
    elif [ "$primary_package_manager" = "xbps" ]; then
        sudo xbps-install -Sy "${packages[@]}"
        
    elif [ "$primary_package_manager" = "zypper" ]; then
        sudo zypper in -y "${packages[@]}"
        
    elif [ "$primary_package_manager" = "rpm-ostree" ]; then
        sudo rpm-ostree install "${packages[@]}"
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
