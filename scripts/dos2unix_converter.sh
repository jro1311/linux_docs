#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Conditional execution based on if the package is installed
if ! command -v dos2unix &> /dev/null; then
    # Installs package(s) based on the package manager detected
    if command -v pacman &> /dev/null; then
        echo "Detected: pacman"
        # Installs package(s)
        sudo pacman -Syu --needed --noconfirm dos2unix
    elif command -v apt &> /dev/null; then
        echo "Detected: apt"
        # Installs package(s)
        sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y dos2unix
    elif command -v dnf &> /dev/null; then
        echo "Detected: dnf"
        # Installs package(s)
        sudo dnf upgrade -y && sudo dnf install -y dos2unix
    elif command -v zypper &> /dev/null; then
        echo "Detected: zypper"
        # Installs package(s)
        sudo zypper ref && sudo zypper -y dup && sudo zypper in -y dos2unix
    else
        echo "Unknown package manager"
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
