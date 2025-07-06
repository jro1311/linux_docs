#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Packages
packages=("btop")

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for package manager
if command -v apt > /dev/null 2>&1; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get install -y "${packages[@]}"
    
    # Checks for AMD GPU
    if echo "$gpu_info" | grep -i "amd" > /dev/null 2>&1; then
        echo "Detected GPU: AMD"
        # Installs package(s)
        sudo apt-get install -y rocm-smi
    fi

elif command -v dnf > /dev/null 2>&1; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf install -y "${packages[@]}"
    
    # Checks for AMD GPU
    if echo "$gpu_info" | grep -i "amd" > /dev/null 2>&1; then
        echo "Detected GPU: AMD"
        # Installs package(s)
        sudo dnf install -y rocm-smi
    fi

elif command -v pacman > /dev/null 2>&1; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
    # Checks for AMD GPU
    if echo "$gpu_info" | grep -i "amd" > /dev/null 2>&1; then
        echo "Detected GPU: AMD"
        # Installs package(s)
        sudo pacman -S --needed --noconfirm rocm-smi-lib
    fi

elif command -v xbps-install > /dev/null 2>&1; then
    echo "Detected: xbps"
    # Installs package(s)
    sudo xbps-install -Sy "${packages[@]}"
    
    # Checks for AMD GPU
    if echo "$gpu_info" | grep -i "amd" > /dev/null 2>&1; then
        echo "Detected GPU: AMD"
        # Installs package(s)
        sudo xbps-install -y ROCm-SMI
    else
        echo "No AMD GPU detected"
    fi

elif command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper in -y "${packages[@]}"

elif command -v snap > /dev/null 2>&1; then
    echo "Detected: snap"
    # Installs package(s)
    sudo snap install "${packages[@]}"

elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "Detected: rpm-ostree"
    # Installs package(s)
    sudo rpm-ostree install "${packages[@]}"
    
    # Checks for AMD GPU
    if echo "$gpu_info" | grep -i "amd" > /dev/null 2>&1; then
        echo "Detected GPU: AMD"
        # Installs package(s)
        sudo rpm-ostree install -y rocm-smi
    fi

else
    echo "Unsupported package manager"
    exit 1
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/btop"
    
# Copies config(s)
cp -v "$HOME/Documents/linux_docs/configs/packages/btop.conf" "$HOME/.config/btop/"

# Prints a conclusive message
echo "btop is now installed"

