#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for X11
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
    echo "Detected Session: X11"
    # Get GPU information
    gpu_info=$(lspci | grep -E "VGA|3D")
    
    # Checks for Intel GPU
    if echo "$gpu_info" | grep -i "intel" &> /dev/null; then
        echo "Detected GPU: Intel"
        echo "VRR should be automatically enabled as long as your monitor supports it"
        read -p "Press enter to exit"
        exit 0
        
    # Checks for AMD GPU
    elif echo "$gpu_info" | grep -i "amd" &> /dev/null; then
        echo "Detected GPU: AMD"
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
        echo "Detected GPU: Nvidia"
        echo "VRR should be automatically enabled as long as your monitor supports it"
        read -p "Press enter to exit"
        exit 0
    else
        echo "Unknown GPU"
        read -p "Press enter to exit"
        exit 1
    fi
    
# Checks for Wayland
elif [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    echo "Detected Session: Wayland"
    echo "Nothing to do"
    read -p "Press enter to exit"
    exit 0
else
    echo "Unknown session"
    read -p "Press enter to exit"
    exit 1
fi

# Prints a conclusive message
echo "VRR will be enabled after reboot or relogin"
read -p "Press enter to exit"
