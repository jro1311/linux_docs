#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for package
if ! command -v shellcheck > /dev/null 2>&1; then
    # Checks for package manager
    if command -v apt > /dev/null 2>&1; then
        echo "Detected: apt"
        # Installs package(s)
        sudo apt-get install -y shellcheck
        
    elif command -v dnf > /dev/null 2>&1; then
        echo "Detected: dnf"
        # Installs package(s)
        sudo dnf install -y shellcheck
        
    elif command -v pacman > /dev/null 2>&1; then
        echo "Detected: pacman"
        # Installs package(s)
        sudo pacman -S --needed --noconfirm shellcheck
        
    elif command -v xbps-install > /dev/null 2>&1; then
        echo "Detected: xbps"
        # Installs package(s)
        sudo xbps-install -Sy shellcheck
        
    elif command -v zypper > /dev/null 2>&1; then
        echo "Detected: zypper"
        # Installs package(s)
        zypper in -y shellcheck
        
    elif command -v rpm-ostree > /dev/null 2>&1; then
        echo "Detected: rpm-ostree"
        # Installs package(s)
        sudo rpm-ostree install shellcheck
        echo "Reboot to use package"
        exit 0
        
    else
        echo "Unsupported package manager"
        exit 1
    fi
fi

# Track if any script fails the syntax check
error_found=0

# Recursively finds all .sh files and checks each for errors
while IFS= read -r -d '' script; do
    if ! shellcheck -x --exclude=1091,2162 "$script" > /dev/null 2>&1; then
        shellcheck -x --exclude=1091,2162 "$script"
        error_found=1
    fi
done < <(find "$HOME/Documents/linux_docs/scripts" -type f -name '*.sh' -print0)

# Prints a conclusive message if no errors were found
if [ "$error_found" -eq 0 ]; then
    echo "No errors were found in any script"
fi
