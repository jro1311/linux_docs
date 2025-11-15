#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Enables Variable Refresh Rate on X11
case "$XDG_SESSION_TYPE" in
    "x11")
        echo "${green}Session: X11 ${reset}"

        # Checks for AMD GPU
        if echo "$gpu_info" | grep -iq "amd"; then
            echo "Detected GPU: AMD"

            # Copies config(s)
            sudo cp -v "$HOME/Documents/linux_docs/configs/system/xorg/10-amdgpu.conf" /etc/X11/xorg.conf.d/

        else
            echo "${yellow}No AMD GPU detected. ${reset}"
            echo "Nothing to do."
            exit 0
        fi
        ;;
    "wayland")
        echo "${green}Session: Wayland ${reset}"
        echo "Nothing to do."
        exit 0
        ;;
    *)
        echo "${red}Unknown session. ${reset}"
        exit 1
        ;;
esac

# Prints a conclusive message
echo "${green}Enabled: Variable Refresh Rate ${reset}"
echo "${green}Setting will be enabled after reboot or relogin. ${reset}"
