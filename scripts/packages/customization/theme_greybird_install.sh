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

# Prints the detected operating system
echo "Detected (ID): $os"
echo "Detected (ID_LIKE): $os_like"

# Installs package(s) based on the package manager detected
if command -v apt > /dev/null 2>&1; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y greybird-gtk-theme
elif command -v dnf > /dev/null 2>&1; then
    echo "Detected: dnf"
    # Installs packages based on the detected operating system
    case "$os" in
        "fedora")
            # Installs package(s)
            sudo dnf upgrade -y && sudo dnf install -y greybird-dark-theme greybird-light-theme
            ;;
        "openmandriva")
            echo "Manual installation required"
            echo "Go to https://github.com/shimmerproject/Greybird/"
            read -p "Press enter to exit"
            exit 0
            ;;
        *)
            case "$os_like" in
                "fedora")
                    # Installs package(s)
                    sudo dnf upgrade -y && sudo dnf install -y greybird-dark-theme greybird-light-theme
                    ;;
                *)
                    echo "Unsupported distribution"
                    read -p "Press enter to exit"
                    exit 1
                    ;;
            esac
            ;;
    esac
elif command -v pacman > /dev/null 2>&1; then
    echo "Detected: pacman"
    # Checks for AUR helper
    if command -v paru > /dev/null 2>&1; then
        echo "Detected: paru"
        # Installs package(s)
        paru -Syu xfce-theme-greybird
    elif command -v yay > /dev/null 2>&1; then
        echo "Detected: yay"
        # Installs package(s)
        yay -Syu xfce-theme-greybird
    else
        # Installs package(s)
        sudo pacman -Syu --needed --noconfirm base-devel git makepkg
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
        
        # Installs package(s)
        yay -Syu xfce-theme-greybird
    fi
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "Detected: rpm-ostree"
    # Installs package(s)
    sudo rpm-ostree upgrade && sudo rpm-ostree install greybird-dark-theme greybird-light-theme
elif command -v xbps-install > /dev/null 2>&1; then
    echo "Detected: xbps"
    echo "Manual installation required"
    echo "Go to https://github.com/shimmerproject/Greybird/"
    read -p "Press enter to exit"
    exit 0
elif command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    echo "Manual installation required"
    echo "Go to https://github.com/shimmerproject/Greybird/"
    read -p "Press enter to exit"
    exit 0
else
    echo "Unsupported package manager"
    echo "Manual installation required"
    echo "Go to https://github.com/shimmerproject/Greybird/"
    read -p "Press enter to exit"
    exit 1
fi

# Prints a conclusive message
echo "Greybird theme is now installed"
read -p "Press enter to exit"
