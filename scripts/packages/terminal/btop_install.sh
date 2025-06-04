#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Gets GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm btop
    
    # Checks for AMD GPU
    if echo "$gpu_info" | grep -i "amd" &> /dev/null; then
        echo "AMD GPU detected"
        # Installs package(s)
        sudo pacman -S --needed rocm-smi-lib
    else
        echo "No AMD GPU detected"
    fi
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y btop
    
    # Checks for AMD GPU
    if echo "$gpu_info" | grep -i "amd" &> /dev/null; then
        echo "AMD GPU detected"
        # Installs package(s)
        sudo apt-get install -y rocm-smi
    else
        echo "No AMD GPU detected"
    fi
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y btop
    
    # Checks for AMD GPU
    if echo "$gpu_info" | grep -i "amd" &> /dev/null; then
        echo "AMD GPU detected"
        # Installs package(s)
        sudo dnf install -y rocm-smi
    else
        echo "No AMD GPU detected"
    fi
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper ref && sudo zypper -y dup && sudo zypper in -y btop
else
    echo "Unknown package manager"
    exit 1
fi

# Makes directory(s)
mkdir -pv "$HOME"/.config/btop
    
# Copies config(s)
cp -v "$HOME"/Documents/linux_docs/configs/packages/btop.conf "$HOME"/.config/btop/

# Prints a conclusive message to end the script
echo "btop is now installed."
