#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Sources all .sh files in $HOME/Documents/linux_docs/configs/system/bash/bashrc.d
shopt -s globstar nullglob

# shellcheck source=/dev/null
for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f "$rc" ]] && source "$rc"
done
unset rc
shopt -u globstar nullglob

# Checks that packages are installed
packages=("smartmontools")
for package in "${packages[@]}"; do
    inverse_check "smartctl" \
        install_packages "$package"
done

# Defines the output file path
output_file="$HOME/Documents/smart_info/$(date +%Y-%m).txt"

if [ -f "$output_file" ]; then
    red_message "Error:" "'$output_file' already exists."
    exit 1
fi

# Finds all SMART devices
devices=$(sudo smartctl --scan | awk '{print $1}')

# Exports SMART info for each device
for device in $devices; do
    if sudo smartctl -a "$device" | tee -a "$output_file" >/dev/null 2>&1; then
        green_message "Success:" "$device"
    else
        red_message "Failed:" "$device"
    fi
done

green_message "Success:" "Exported SMART info to '$output_file'."
