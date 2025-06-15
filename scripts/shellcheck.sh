#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for package
if ! command -v shellcheck &> /dev/null; then
    # Installs package(s) based on the package manager detected
    if command -v pacman &> /dev/null; then
        echo "Detected: pacman"
        # Installs package(s)
        sudo pacman -Syu --needed --noconfirm shellcheck
    elif command -v apt &> /dev/null; then
        echo "Detected: apt"
        # Installs package(s)
        sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y shellcheck
    elif command -v dnf &> /dev/null; then
        echo "Detected: dnf"
        # Installs package(s)
        sudo dnf upgrade -y && sudo dnf install -y shellcheck
    elif command -v zypper &> /dev/null; then
        echo "Detected: zypper"
        # Installs package(s)
        sudo zypper ref && sudo zypper -y dup && sudo zypper in -y shellcheck
    elif command -v xbps-install &> /dev/null; then
        echo "Detected: xbps"
        # Installs package(s)
        sudo xbps-install -Su xbps && sudo xbps-install -u && sudo xbps-install -y shellcheck
    else
        echo "Unknown package manager"
        read -p "Press enter to exit"
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
    echo "No errors were found in any script"
fi
read -p "Press enter to exit"
