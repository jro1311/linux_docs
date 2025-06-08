#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for X11
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
    echo "Detected: X11"
    # Gets GPU information
    gpu_info=$(lspci | grep -E "VGA|3D")
    
    # Checks for Intel GPU
    if echo "$gpu_info" | grep -i "intel" &> /dev/null; then
        echo "Intel GPU detected."
        echo "Variable refresh rate should be automatically enabled as long as your monitor supports it."
        exit 1
        
    # Checks for AMD GPU
    elif echo "$gpu_info" | grep -i "amd" &> /dev/null; then
        echo "AMD GPU detected."
        # Creates manual config
        sudo tee /etc/X11/xorg.conf.d/20-amdgpu.conf <<- 'EOF'

        Section "OutputClass"
            Identifier "AMD"
            MatchDriver "amdgpu"
            Driver "amdgpu"
        EndSection

        Section "Device"
            Option "VariableRefresh" "true"
        EndSection
        
EOF

    # Checks for Nvidia GPU
    elif echo "$gpu_info" | grep -i "nvidia" &> /dev/null; then
        echo "Nvidia GPU detected."
        echo "Variable refresh rate should be automatically enabled as long as your monitor supports it."
        exit 1
    else
        echo "No Intel, AMD, or Nvidia GPU detected."
        exit 1
    fi
    
# Checks for Wayland
elif [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    echo "Detected: Wayland"
    echo "Nothing to do."
    exit 1
else
    echo "Unknown session type."
    exit 1
fi

# Prints a conclusive message
echo "Variable refresh rate will be enabled after reboot or relogin."
