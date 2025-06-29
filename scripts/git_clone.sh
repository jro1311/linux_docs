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
if ! command -v git &> /dev/null; then
    # Prints the detected operating system
    echo "Detected (ID): $os"
    echo "Detected (ID_LIKE): $os_like"
    
    # Installs package(s) based on the package manager detected
    if command -v apt &> /dev/null; then
        echo "Detected: apt"
        # Installs package(s)
        sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y git
    elif command -v dnf &> /dev/null; then
        echo "Detected: dnf"
        # Installs package(s)
        sudo dnf upgrade -y && sudo dnf install -y git
    elif command -v pacman &> /dev/null; then
        echo "Detected: pacman"
        # Installs package(s)
        sudo pacman -Syu --needed --noconfirm git
    elif command -v rpm-ostree &> /dev/null; then
        echo "Detected: rpm-ostree"
        # Installs package(s)
        sudo rpm-ostree upgrade && sudo rpm-ostree install git
        echo "Reboot to use package"
        read -p "Press enter to exit"
        exit 0
    elif command -v xbps-install &> /dev/null; then
        echo "Detected: xbps"
        # Installs package(s)
        sudo xbps-install -Su xbps && sudo xbps-install -u && sudo xbps-install -y git
    elif command -v zypper &> /dev/null; then
        echo "Detected: zypper"
        # Installs package(s)
        if [ "$os" = "opensuse-tumbleweed" ] || [ "$os" = "opensuse-slowroll" ]; then
            sudo zypper ref && sudo zypper dup -y && sudo zypper in -y git
        elif [ "$os" = "opensuse-leap" ]; then
            sudo zypper ref && sudo zypper up -y && sudo zypper in -y git
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

# Print a conclusive message
echo "Git clone complete"
read -p "Press enter to exit"
