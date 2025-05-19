#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Detects the operating system and stores it in a variable
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS="${ID:-unknown}"
    
    # Fallback to $OS if ID_LIKE is missing
    OS_LIKE="${ID_LIKE:-$OS}"
else
    echo "Unable to detect the operating system"
    exit 1
fi

# Converts the variable into lowercase
OS=$(echo "${OS:-unknown}" | tr '[:upper:]' '[:lower:]')
OS_LIKE=$(echo "$OS_LIKE" | tr '[:upper:]' '[:lower:]')

# Prints the detected operating system
echo "Detected: $OS"

# Installs packages based on the detected operating system
case "$OS" in
    "arch")
        sudo pacman -Syu --needed --noconfirm
        ;;
    "debian"|"ubuntu")
        sudo apt update && sudo apt upgrade -y && sudo apt install -y
        ;;
    "fedora")
        sudo dnf upgrade -y && sudo dnf install -y
        ;;
    "opensuse")
        sudo zypper ref && sudo zypper in -y
        ;;
    *)
        case "$OS_LIKE" in
            "arch")
                sudo pacman -Syu --needed --noconfirm
                ;;
            "debian"|"ubuntu")
                sudo apt update && sudo apt upgrade -y && sudo apt install -y
                ;;
            "fedora")
                sudo dnf upgrade -y && sudo dnf install -y
                ;;
            "opensuse")
                sudo zypper ref && sudo zypper in -y
                ;;
            *)
                echo "Unsupported distribution: $OS"
                exit 1
                ;;
        esac
        ;;
esac

# Prints a conclusive message to end the script
echo "x is now installed."
