#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Gets GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for Intel GPU
if echo "$gpu_info" | grep -i "intel" &> /dev/null; then
    echo "Intel GPU detected."
    
# Checks for AMD GPU
elif echo "$gpu_info" | grep -i "amd" &> /dev/null; then
    echo "AMD GPU detected."
    
# Checks for Nvidia GPU
elif echo "$gpu_info" | grep -i "nvidia" &> /dev/null; then
    echo "Nvidia GPU detected."
else
     echo "No Intel, AMD, or Nvidia GPU detected"
fi

# Prints a conclusive message to end the script
echo "x is now installed."
