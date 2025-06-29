#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Detects the operating system and stores it in a variable
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
else
    echo "Unable to detect the operating system"
    read -p "Press enter to exit"
    exit 1
fi

# Converts the variable into lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

# Checks for package
if ! command -v dos2unix &> /dev/null; then
    # Prints the detected operating system
    echo "Detected (ID): $os"
    echo "Detected (ID_LIKE): $os_like"
    
    # Installs package(s) based on the package manager detected
    if command -v apt &> /dev/null; then
        echo "Detected: apt"
        # Installs package(s)
        sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y dos2unix
    elif command -v dnf &> /dev/null; then
        echo "Detected: dnf"
        # Installs package(s)
        sudo dnf upgrade -y && sudo dnf install -y dos2unix
    elif command -v pacman &> /dev/null; then
        echo "Detected: pacman"
        # Installs package(s)
        sudo pacman -Syu --needed --noconfirm dos2unix
    elif command -v rpm-ostree &> /dev/null; then
        echo "Detected: rpm-ostree"
        # Installs package(s)
        sudo rpm-ostree upgrade && sudo rpm-ostree install dos2unix
        echo "Reboot to use package"
        read -p "Press enter to exit"
        exit 0
    elif command -v xbps-install &> /dev/null; then
        echo "Detected: xbps"
        # Installs package(s)
        sudo xbps-install -Su xbps && sudo xbps-install -u && sudo xbps-install -y dos2unix
    elif command -v zypper &> /dev/null; then
        echo "Detected: zypper"
        # Installs package(s)
        if [ "$os" = "opensuse-tumbleweed" ] || [ "$os" = "opensuse-slowroll" ]; then
            sudo zypper ref && sudo zypper dup -y && sudo zypper in -y dos2unix
        elif [ "$os" = "opensuse-leap" ]; then
            sudo zypper ref && sudo zypper up -y && sudo zypper in -y dos2unix
        else
            echo "Unsupported operating system"
            read -p "Press enter to exit"
            exit 1
        fi
    else
        echo "Unsupported package manager"
        read -p "Press enter to exit"
        exit 1
    fi
fi

# Prompts the user for input
read -r -p "Enter the path of the directory to process (default is $HOME/Documents/): " target_dir
    
# Uses default if no input is given
target_dir=${target_dir:-$HOME/Documents/}

# Expands ~ or $HOME to the full path
target_dir="${target_dir/#~/$HOME}"
target_dir="${target_dir/#\$HOME/$HOME}"

# Ensures the directory exists
if [ ! -d "$target_dir" ]; then
    echo "$target_dir does not exist"
    read -p "Press enter to exit"
    exit 1
fi

# Prints target directory
echo "Target: $target_dir"
    
# Recursively finds all .md, .txt, and .sh files and converts them to unix format
for ext in md txt sh; do
    find "$target_dir" -type f -name "*.$ext" -exec dos2unix {} +
done

# Prints a conclusive message
echo "Conversion complete"
read -p "Press enter to exit"
