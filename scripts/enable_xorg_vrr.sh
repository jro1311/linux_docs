#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for session type
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
    echo "Detected Session: X11"
    # Checks for AMD GPU
    if echo "$gpu_info" | grep -iq "amd"; then
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
    else
        echo "No AMD GPU detected"
        echo "Nothing to do"
        exit 0
    fi
elif [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    echo "Detected Session: Wayland"
    echo "Nothing to do"
    exit 0
else
    echo "Unknown session"
    exit 1
fi

# Prints a conclusive message
echo "VRR will be enabled after reboot or relogin"
