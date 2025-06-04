#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Detects the operating system and stores it in a variable
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    
    # Fallback to $os if ID_LIKE is missing
    os_like="${ID_LIKE:-$os}"
else
    echo "Unable to detect the operating system"
    exit 1
fi

# Converts the variable into lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

# Prints the detected operating system
echo "Detected (ID): $os"
echo "Detected (ID_LIKE): $os_like"

# Installs packages based on the detected operating system
case "$os" in
    "arch")
        sudo pacman -Syu --needed --noconfirm
        ;;
    "debian"|"ubuntu")
        sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y
        ;;
    "fedora")
        sudo dnf upgrade -y && sudo dnf install -y
        ;;
    "opensuse")
        sudo zypper ref && sudo zypper in -y
        ;;
    *)
        case "$os_like" in
            "arch")
                sudo pacman -Syu --needed --noconfirm
                ;;
            "debian"|"ubuntu debian")
                sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y
                ;;
            "fedora")
                sudo dnf upgrade -y && sudo dnf install -y
                ;;
            "opensuse")
                sudo zypper ref && sudo zypper in -y
                ;;
            *)
                echo "Unsupported distribution: $os"
                exit 1
                ;;
        esac
        ;;
esac

# Prints a conclusive message to end the script
echo "x is now installed."
