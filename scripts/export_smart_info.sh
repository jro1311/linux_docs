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
if ! command -v smartctl > /dev/null 2>&1; then
    # Prints the detected operating system
    echo "Detected (ID): $os"
    echo "Detected (ID_LIKE): $os_like"
    
    # Installs package(s) based on the package manager detected
    if command -v apt > /dev/null 2>&1; then
        echo "Detected: apt"
        # Installs package(s)
        sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y smartmontools
    elif command -v pacman > /dev/null 2>&1; then
        echo "Detected: pacman"
        # Installs package(s)
        sudo pacman -Syu --needed --noconfirm smartmontools
    elif command -v dnf > /dev/null 2>&1; then
        echo "Detected: dnf"
        # Installs package(s)
        sudo dnf upgrade -y && sudo dnf install -y smartmontools
    elif command -v rpm-ostree > /dev/null 2>&1; then
        echo "Detected: rpm-ostree"
        # Installs package(s)
        sudo rpm-ostree upgrade && sudo rpm-ostree install smartmontools
        echo "Reboot to use package"
        read -p "Press enter to exit"
        exit 0
    elif command -v xbps-install > /dev/null 2>&1; then
        echo "Detected: xbps"
        # Installs package(s)
        sudo xbps-install -Suy xbps && sudo xbps-install -uy && sudo xbps-install -y smartmontools
    elif command -v zypper > /dev/null 2>&1; then
        echo "Detected: zypper"
        # Installs package(s)
        if [ "$os" = "opensuse-tumbleweed" ] || [ "$os" = "opensuse-slowroll" ]; then
            sudo zypper ref && sudo zypper dup -y && sudo zypper in -y smartmontools
        elif [ "$os" = "opensuse-leap" ]; then
            sudo zypper ref && sudo zypper up -y && sudo zypper in -y smartmontools
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

# Defines the output file path
output_file="$HOME/Documents/linux_docs/documentation/smart_info/$(date +%Y-%m).txt"

# Finds all SMART devices
devices=$(sudo smartctl --scan | awk '{print $1}')

# Exports SMART info for each device
for device in $devices; do
    sudo smartctl -a "$device" | tee -a "$output_file" > /dev/null 2>&1
done

# Prints a conclusive message
echo "SMART info has been successfully exported"
read -p "Press enter to exit"
