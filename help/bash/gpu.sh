#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for AMD GPU
if echo "$gpu_info" | grep -Fiq "amd"; then
    echo "${green}GPU Detected:${reset} AMD"
else
    echo "${yellow}No AMD GPU detected.${reset}"
fi

# Checks for Intel GPU
if echo "$gpu_info" | grep -Fiq "intel"; then
    echo "${green}Detected GPU:${reset} Intel"
else
    echo "${yellow}No Intel GPU detected.${reset}"
fi

# Checks for Nvidia GPU
if echo "$gpu_info" | grep -Fiq "nvidia"; then
    echo "${green}Detected GPU:${reset} Nvidia"
else
    echo "${yellow}No Nvidia GPU detected.${reset}"
fi
