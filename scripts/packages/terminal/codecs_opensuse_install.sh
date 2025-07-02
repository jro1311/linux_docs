#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for package manager
if ! command -v zypper > /dev/null 2>&1; then
    echo "Unsupported package manager"
    read -p "Press enter to exit"
    exit 1
fi

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

# Prints the detected operating system
echo "Detected (ID): $os"
echo "Detected (ID_LIKE): $os_like"

# Checks for zypper
if command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    # Installs package(s)
    if [ "$os" = "opensuse-tumbleweed" ] || [ "$os" = "opensuse-slowroll" ]; then
        sudo zypper ref && sudo zypper dup -y && sudo zypper in -y opi
    elif [ "$os" = "opensuse-leap" ]; then
        sudo zypper ref && sudo zypper up -y && sudo zypper in -y opi
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

# Installs package(s)
opi codecs

# Prints a conclusive message
echo "Multimedia codecs are now installed"
read -p "Press enter to exit"
