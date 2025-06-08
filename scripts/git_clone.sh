#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Conditional execution based on if the package is installed
if ! command -v git &> /dev/null; then
    # Installs package(s) based on the package manager detected
    if command -v pacman &> /dev/null; then
        echo "Detected: pacman"
        # Installs package(s)
        sudo pacman -Syu --needed --noconfirm git
    elif command -v apt &> /dev/null; then
        echo "Detected: apt"
        # Installs package(s)
        sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y git
    elif command -v dnf &> /dev/null; then
        echo "Detected: dnf"
        # Installs package(s)
        sudo dnf upgrade -y && sudo dnf install -y git
    elif command -v zypper &> /dev/null; then
        echo "Detected: zypper"
        # Installs package(s)
        sudo zypper ref && sudo zypper -y dup && sudo zypper in -y git
    else
        echo "Unknown package manager"
        exit 1
    fi
fi

# Define the source and base directories
source_dir="$HOME/Documents/linux_docs"
base_dir="$HOME/Documents/linux_docs_old"

# Checks if the base destination exists
if [ -d "$base_dir" ]; then
    # Uses numbered naming logic
    count=1
    new_dir="$base_dir"
    while [ -d "$new_dir" ]; do
        new_dir="$base_dir$count"
        count=$((count + 1))
    done
    mv -v "$source_dir" "$new_dir"
else
    # Performs the first rename
    mv -v "$source_dir" "$base_dir"
fi

# Changes current directory
cd "$HOME/Documents"

# Clones git repository
git clone https://github.com/jro1311/linux_docs.git

# Print a conclusive message to end the script
echo "Git clone complete."
