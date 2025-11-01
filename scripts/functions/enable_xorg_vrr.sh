#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for session type
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
    echo "${green}Detected Session: X11 ${reset}"
    
    # Checks for AMD GPU
    if echo "$gpu_info" | grep -iq "amd"; then
        echo "Detected GPU: AMD"
        
        # Copies config(s)
        sudo cp -v "$HOME/Documents/linux_docs/configs/packages/xorg/10-amdgpu.conf" /etc/X11/xorg.conf.d/

    else
        echo "${yellow}No AMD GPU detected ${reset}"
        echo "${green} Nothing to do ${reset}"
        exit 0
    fi
    
elif [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    echo "${green}Detected Session: Wayland ${reset}"
    echo "${green}Nothing to do ${reset}"
    exit 0
    
else
    echo "${red} Unknown session ${reset}"
    exit 1
fi

# Prints a conclusive message
echo "${green}VRR will be enabled after reboot or relogin ${reset}"
