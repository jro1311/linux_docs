#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for package
if ! command -v shellcheck > /dev/null 2>&1; then
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
    packages=("shellcheck")

    # Checks for package manager and installs package(s)
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
        echo "${yellow}Reboot to use package${reset}"
        exit 0
        
    else
        echo "${red}Unsupported package manager${reset}"
        exit 1
    fi
fi

# Track if any script fails the syntax check
error_found=0

# Recursively finds all .sh files and checks each for errors
while IFS= read -r -d '' script; do
    if ! shellcheck -x --exclude=2162 "$script" > /dev/null 2>&1; then
        shellcheck -x --exclude=2162 "$script"
        error_found=1
    fi
done < <(find "$HOME/Documents/linux_docs/scripts" -type f -name '*.sh' -print0)

# Prints a conclusive message if no errors were found
if [ "$error_found" -eq 0 ]; then
    echo "${green}No errors were found in any script ${reset}"
fi
