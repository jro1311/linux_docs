#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# V1

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

# V2

gpu_info=$(lspci | grep -E "VGA|3D")
gpu_vendors=(
    amd
    nvidia
    intel
)

gpu_detected_list=()

for brand in "${gpu_vendors[@]}"; do
    printf -v "${brand}_gpu_detected" 0
done

for brand in "${gpu_vendors[@]}"; do
    if echo "$gpu_info" | grep -Fiq "$brand"; then
        printf -v "${brand}_gpu_detected" 1
        gpu_detected_list+=("$brand")
    fi
done

gpu_detected_csv="$(printf '%s, ' "${gpu_detected_list[@]}")"
gpu_detected_csv="${gpu_detected_csv%, }"

echo "${green}GPU(s):${reset}" "$gpu_detected_csv"
