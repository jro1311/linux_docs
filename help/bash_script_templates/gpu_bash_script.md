#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for Intel GPU
if echo "$gpu_info" | grep -i "intel" &> /dev/null; then
    echo "Detected GPU: Intel"
    
# Checks for AMD GPU
elif echo "$gpu_info" | grep -i "amd" &> /dev/null; then
    echo "Detected GPU: AMD"
    
# Checks for Nvidia GPU
elif echo "$gpu_info" | grep -i "nvidia" &> /dev/null; then
    echo "Detected GPU: Nvidia"
else
    echo "Unknown GPU"
    read -p "Press enter to exit"
    exit 1
fi

# Prints a conclusive message
echo "x is now installed"
read -p "Press enter to exit"
