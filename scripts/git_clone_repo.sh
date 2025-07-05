#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for package
if ! command -v git > /dev/null 2>&1; then
    # Checks for package manager
    if command -v apt > /dev/null 2>&1; then
        echo "Detected: apt"
        # Installs package(s)
        sudo apt-get install -y git
        
    elif command -v dnf > /dev/null 2>&1; then
        echo "Detected: dnf"
        # Installs package(s)
        sudo dnf install -y git
        
    elif command -v pacman > /dev/null 2>&1; then
        echo "Detected: pacman"
        # Installs package(s)
        sudo pacman -S --needed --noconfirm git
        
    elif command -v xbps-install > /dev/null 2>&1; then
        echo "Detected: xbps"
        # Installs package(s)
        sudo xbps-install -Sy git
        
    elif command -v zypper > /dev/null 2>&1; then
        echo "Detected: zypper"
        # Installs package(s)
        zypper in -y dos2unix
        
    elif command -v rpm-ostree > /dev/null 2>&1; then
        echo "Detected: rpm-ostree"
        # Installs package(s)
        sudo rpm-ostree install git
        echo "Reboot to use package"
        exit 0
        
    else
        echo "Unsupported package manager"
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
echo "Git clone complete"
