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
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y distrobox podman
elif command -v dnf > /dev/null 2>&1; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y distrobox podman
elif command -v pacman > /dev/null 2>&1; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm distrobox podman
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "Detected: rpm-ostree"
    # Installs package(s)
    sudo rpm-ostree upgrade && sudo rpm-ostree install distrobox podman
    echo "Reboot to use package"
    read -p "Press enter to exit"
    exit 0
elif command -v xbps-install > /dev/null 2>&1; then
    echo "Detected: xbps"
    # Installs package(s)
    sudo xbps-install -Suy xbps && sudo xbps-install -uy && sudo xbps-install -y distrobox podman
elif command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    # Installs package(s)
    if [ "$os" = "opensuse-tumbleweed" ] || [ "$os" = "opensuse-slowroll" ]; then
        sudo zypper ref && sudo zypper dup -y && sudo zypper in -y distrobox podman
    elif [ "$os" = "opensuse-leap" ]; then
        sudo zypper ref && sudo zypper up -y && sudo zypper in -y distrobox podman
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

# Prompts the user for input
read -r -p "Enter a container image to install (arch/debian/fedora/opensuse/ubuntu): " image

# Converts $image to lowercase if input was uppercase
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
    read -p "Press enter to exit"
    exit 1
fi

# Prints a conclusive message
echo "Distrobox is now installed"
read -p "Press enter to exit"
