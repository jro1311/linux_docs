#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Detects the session type and stores in a variable
session_type=$(echo $XDG_SESSION_TYPE)

# Checks for X11
if echo "$session_type" | grep "x11" &> /dev/null; then
    echo "X11 detected"
    # Gets GPU information
    gpu_info=$(lspci | grep -E "VGA|3D")
    
    # Checks for Intel GPU
    if echo "$gpu_info" | grep -i "intel" &> /dev/null; then
        echo "Intel GPU detected"
        echo "VRR should be automatically enabled as long as your monitor supports it"
        exit 1
        
    # Checks for AMD GPU
    elif echo "$gpu_info" | grep -i "amd" &> /dev/null; then
        echo "AMD GPU detected"
        # Creates a manual config
        echo tee /etc/X11/xorg.conf.d/20-radeon.conf <- 'EOF'

        Section "Device"
            Identifier "Card0"
            Driver "amdgpu"
            Option "VariableRefresh" "true"
        EndSection

        EOF
        
    # Checks for Nvidia GPU
    elif echo "$gpu_info" | grep -i "nvidia" &> /dev/null; then
        echo "Nvidia GPU detected"
        echo "VRR should be automatically enabled as long as your monitor supports it"
        exit 1
    else
        echo "No Intel, AMD, or Nvidia GPU detected"
        exit 1
    fi
    
# Checks for Wayland
elif echo "$session_type" | grep "wayland" &> /dev/null; then
    echo "Wayland detected"
    echo "Nothing to do"
    exit 1
else
    echo "Unknown session type"
    exit 1
fi

# Prints a conclusive message to end the script
echo "VRR will be enabled after reboot or relogin."
