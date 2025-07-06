#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for init system
if ps -p 1 -o comm= | grep -q "systemd"; then
    echo "Detected: systemd"
else
    echo "Unsupported init system"
    exit 1
fi

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
packages=("snapd")
aur_packages=("snapd")

# Checks for package manager
if command -v apt > /dev/null 2>&1; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get install -y "${packages[@]}"
    sudo snap install snapd

elif command -v dnf > /dev/null 2>&1; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf install -y "${packages[@]}"

elif command -v pacman > /dev/null 2>&1; then
    echo "Detected: pacman"
    # Checks for AUR helper
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
        rm -rf yay
        paru -S "${aur_packages[@]}"
    fi

    # Enables snapd
    sudo systemctl enable --now snapd.socket

elif command -v xbps-install > /dev/null 2>&1; then
    echo "Detected: xbps"
    echo "No package available"
    exit 1

elif command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    if [ "$os" = "opensuse-tumbleweed" ] || [ "$os" = "opensuse-slowroll" ]; then
        # Adds repo(s)
        sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Tumbleweed snappy
        sudo zypper --gpg-auto-import-keys refresh
        
        # Installs package(s)
        sudo zypper in -y "${packages[@]}"
    elif [ "$os" = "opensuse-leap" ]; then
        # Adds repo(s)
        sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Leap_16.0 snappy
        sudo zypper --gpg-auto-import-keys refresh
        
        # Installs package(s)
        sudo zypper in -y "${packages[@]}"
    else
        echo "Unsupported operating system"
        exit 1
    fi
    
    # Enables snapd
    sudo systemctl enable --now snapd
    
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "Detected: rpm-ostree"
    # Installs package(s)
    sudo rpm-ostree install "${packages[@]}"
    
else
    echo "Unsupported package manager"
    exit 1
fi

# Prints a conclusive message
echo "Snap is now installed"

