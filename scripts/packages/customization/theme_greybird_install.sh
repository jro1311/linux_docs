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
aur_packages=("xfce-theme-greybird")

# Checks for package manager
if command -v apt > /dev/null 2>&1; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get install -y greybird-gtk-theme

elif command -v dnf > /dev/null 2>&1; then
    echo "Detected: dnf"
    if [ "$os" = "openmandriva" ]; then
        echo "Detected: OpenMandriva"
        echo "Manual installation required"
        echo "Go to https://github.com/shimmerproject/Greybird/"
        exit 0
    else 
        # Installs package(s)
        sudo dnf install -y greybird-dark-theme greybird-light-theme
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

elif command -v xbps-install > /dev/null 2>&1; then
    echo "Detected: xbps"
    echo "Manual installation required"
    echo "Go to https://github.com/shimmerproject/Greybird/"
    exit 0
    #sudo xbps-install -Sy "${packages[@]}"

elif command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    echo "Manual installation required"
    echo "Go to https://github.com/shimmerproject/Greybird/"
    exit 0
    #sudo zypper in -y "${packages[@]}"

elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "Detected: rpm-ostree"
    # Installs package(s)
    sudo rpm-ostree install greybird-dark-theme greybird-light-theme

else
    echo "Unsupported package manager"
    exit 1
fi

# Prints a conclusive message
echo "Greybird theme is now installed"

