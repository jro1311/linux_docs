#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Detect the operating system
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
else
    echo "Unable to detect the operating system"
    exit 1
fi

# Convert operating system to lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

# Packages
aur_packages=("ttf-ms-win11-auto")

# Checks for package manager
if command -v apt > /dev/null 2>&1; then
    echo "Detected: apt"
    sudo apt-get install -y software-properties-common
    
    # Executes commands based on the operating system
    case "$os" in
        "debian")
            # Adds repo(s)
            sudo apt-add-repository -y contrib non-free-firmware
            ;;
        "ubuntu")
            # Adds repo(s)
            sudo add-apt-repository multiverse
            ;;
        *)
            case "$os_like" in
                "debian")
                    # Adds repo(s)
                    sudo apt-add-repository -y contrib non-free-firmware
                    ;;
                "ubuntu debian")
                    # Adds repo(s)
                    sudo add-apt-repository multiverse
                    ;;
                *)
                    echo "Unsupported distribution"
                    exit 1
                    ;;
            esac
            ;;
    esac
    
    # Installs package(s)
    sudo apt-get install -y fontconfig ttf-mscorefonts-installer

elif command -v dnf > /dev/null 2>&1; then
    echo "Detected: dnf"
    if [ "$os" = "openmandriva" ]; then
        echo "Detected: OpenMandriva"
        echo "Manual installation required"
        exit 0
    else 
        # Installs package(s)
        sudo dnf install -y cabextract curl fontconfig xorg-x11-font-utils
        sudo dnf install -y https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
    fi

elif command -v pacman > /dev/null 2>&1; then
    echo "Detected: pacman"
    if command -v paru > /dev/null 2>&1; then
        echo "Detected: paru"
        # Installs package(s)
        paru -S "${aur_packages[@]}"
    elif command -v yay > /dev/null 2>&1; then
        echo "Detected: yay"
        # Installs package(s)
        yay -S "${aur_packages[@]}"
    else
        # Installs package(s)
        sudo pacman -S --needed --noconfirm base-devel git makepkg
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si --noconfirm
        cd ..
        rm -rf paru
        paru -S "${aur_packages[@]}"
    fi

elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "Detected: rpm-ostree"
    echo "Manual installation required"
    exit 0

elif command -v xbps-install > /dev/null 2>&1; then
    echo "Detected: xbps"
    echo "Manual installation required"
    exit 0

elif command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper in -y fetchmsttfonts fontconfig

else
    echo "Unsupported package manager"
    echo "Manual installation required"
    exit 1
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/fontconfig"

# Copies config(s)
cp -v "$HOME/Documents/linux_docs/configs/packages/fonts.conf" "$HOME/.config/fontconfig/"

# Prints a conclusive message
echo "Microsoft fonts is now installed"
