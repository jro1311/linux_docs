#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm distrobox podman
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y distrobox podman
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y distrobox podman
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper ref && sudo zypper dup -y && sudo zypper in -y distrobox podman
elif command -v xbps-install &> /dev/null; then
    echo "Detected: xbps"
    # Installs package(s)
    sudo xbps-install -u -y && sudo xbps-install -y distrobox podman
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
