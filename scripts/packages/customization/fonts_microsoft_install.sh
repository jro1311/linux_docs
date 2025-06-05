#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs AUR helper yay if it is not already installed
    if ! command -v yay > /dev/null 2>&1; then
        echo "yay is not installed. Installing yay..."
        sudo pacman -Syu --needed --noconfirm fontconfig git makepkg
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    else
        echo "yay is already installed"
    fi
    
    # Installs package(s)
    yay -Syu ttf-ms-win11-auto
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y software-properties-common
    
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
        "debian")
            # Adds contrib and non-free repositories
            sudo apt-add-repository -y contrib non-free-firmware
            ;;
        "ubuntu")
            # Adds repo(s)
            sudo add-apt-repository multiverse
            ;;
        *)
            case "$os_like" in
                "debian")
                    # Adds contrib and non-free repositories
                    sudo apt-add-repository -y contrib non-free-firmware
                    ;;
                "ubuntu debian")
                    # Adds repo(s)
                    sudo add-apt-repository multiverse
                    ;;
                *)
                    echo "Unsupported distribution: $os"
                    exit 1
                    ;;
            esac
            ;;
    esac
    
    # Installs package(s)
    sudo apt-get install -y fontconfig ttf-mscorefonts-installer
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y cabextract curl fontconfig xorg-x11-font-utils
    sudo dnf install -y https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper ref && sudo zypper -y dup && sudo zypper in -y fetchmsttfonts fontconfig
else
    echo "Unknown package manager"
    echo "Manual installation required"
    exit 1
fi

# Makes directory
mkdir -pv ~/.config/fontconfig

# Copies config(s)
cp -v "$HOME"/Documents/linux_docs/configs/packages/fonts.conf "$HOME"/.config/fontconfig/

# Prints a conclusive message to end the script
echo "Microsoft fonts is now installed."
