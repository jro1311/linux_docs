#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
if command -v tput &>/dev/null; then
    red=$(tput setaf 1)
    green=$(tput setaf 2)
    yellow=$(tput setaf 3)
    blue=$(tput setaf 4)
    reset=$(tput sgr0)
else
    # Fallback for systems without tput
    red=$'\033[31m'
    green=$'\033[32m'
    yellow=$'\033[33m'
    blue=$'\033[34m'
    reset=$'\033[0m'
fi

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for AMD GPU
if echo "$gpu_info" | grep -Fiq "amd"; then
    echo "${green}Detected:${reset} AMD GPU"
else
    echo "${yellow}Not detected:${reset} AMD GPU"
fi

# Checks for Intel GPU
if echo "$gpu_info" | grep -Fiq "intel"; then
    echo "${green}Detected:${reset} Intel GPU"
else
    echo "${yellow}Not detected:${reset} Intel GPU"
fi

# Checks for Nvidia GPU
if echo "$gpu_info" | grep -Fiq "nvidia"; then
    echo "${green}Detected:${reset} Nvidia GPU"
else
    echo "${yellow}Not detected:${reset} Nvidia GPU"
fi
