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
packages=("distrobox" "podman")

# Checks for package manager
if command -v apt > /dev/null 2>&1; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get install -y "${packages[@]}"
    
elif command -v dnf > /dev/null 2>&1; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf install -y "${packages[@]}"
    
elif command -v pacman > /dev/null 2>&1; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -S --needed --noconfirm "${packages[@]}"

elif command -v xbps-install > /dev/null 2>&1; then
    echo "Detected: xbps"
    # Installs package(s)
    sudo xbps-install -Sy "${packages[@]}"

elif command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper in -y "${packages[@]}"
    
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "Detected: rpm-ostree"
    # Installs package(s)
    sudo rpm-ostree install "${packages[@]}"
    echo "Reboot to use package"
    exit 0

else
    echo "Unsupported package manager"
    exit 1
fi

# Prompts the user for input
read -r -p "Enter a container image to install (arch/debian/fedora/opensuse/ubuntu): " image

# Convert image to lowercase
image=$(echo "$image" | tr '[:upper:]' '[:lower:]')

# Prints selected image
echo "Image: $image"

# Creates distrobox instance based on user input
if [ "$image" = "arch" ]; then
    distrobox create -i quay.io/toolbx/arch-toolbox:latest
elif [ "$image" = "debian" ]; then
    distrobox create -i quay.io/toolbx-images/debian-toolbox:latest
elif [ "$image" = "fedora" ]; then
    distrobox create -i quay.io/fedora/fedora:rawhide
elif [ "$image" = "opensuse" ]; then
    distrobox create -i registry.opensuse.org/opensuse/distrobox:latest
elif [ "$image" = "ubuntu" ]; then
    distrobox create -i quay.io/toolbx/ubuntu-toolbox:latest
else
    echo "Unsupported image"
    exit 1
fi

# Prints a conclusive message
echo "Distrobox is now installed"

