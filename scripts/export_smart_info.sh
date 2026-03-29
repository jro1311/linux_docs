#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Sources all .sh files in $HOME/Documents/linux_docs/configs/system/bash/bashrc.d
shopt -s globstar nullglob

# shellcheck source=/dev/null
for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f $rc ]] && source "$rc"
done
unset rc

shopt -u globstar nullglob

if ! command -v smartctl >/dev/null 2>&1; then

    # Define primary package manager
    primary_package_manager="unknown"
    primary_package_managers=(apt dnf eopkg pacman xbps-install zypper rpm-ostree)

    for cmd in "${primary_package_managers[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            primary_package_manager="$cmd"
            break
        fi
    done

    # Normalizes xbps-install to xbps
    if [ "$primary_package_manager" = "xbps-install" ]; then
        primary_package_manager="xbps"
    fi

    if [ "$primary_package_manager" != "unknown" ]; then
        green_message "Primary Package Manager: $primary_package_manager"
    fi

    packages=("smartmontools")
    install_packages "${packages[@]}"

fi

# Defines the output file path
output_file="$HOME/Documents/linux_docs/documentation/smart_info/$(date +%Y-%m).txt"

# Finds all SMART devices
devices=$(sudo smartctl --scan | awk '{print $1}')

# Exports SMART info for each device
for device in $devices; do
    sudo smartctl -a "$device" | tee -a "$output_file" >/dev/null 2>&1
done

green_message "SMART info has been exported."
