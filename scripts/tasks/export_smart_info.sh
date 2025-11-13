#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# List of packages
packages=("smartmontools")

# Checks for package
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
        echo "${green}Primary Package Manager: $primary_package_manager ${reset}"
    fi

    # Checks for package manager and installs package(s)
    case $primary_package_manager in
        "apt")
            sudo apt-get install -y "${packages[@]}"
            ;;
        "dnf")
            sudo dnf install -y "${packages[@]}"
            ;;
        "eopkg")
            sudo eopkg install -y "${packages[@]}"
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm "${packages[@]}"
            ;;
        "xbps")
            sudo xbps-install -Sy "${packages[@]}"
            ;;
        "zypper")
            sudo zypper in -y "${packages[@]}"
            ;;
        "rpm-ostree")
            sudo rpm-ostree install "${packages[@]}"
            echo "${yellow}Reboot and run script again to complete. ${reset}"
            exit 0
            ;;
        *)
            echo "${red}Unsupported package manager. ${reset}"
            exit 1
            ;;
    esac
fi

# Defines the output file path
output_file="$HOME/Documents/linux_docs/documentation/smart_info/$(date +%Y-%m).txt"

# Finds all SMART devices
devices=$(sudo smartctl --scan | awk '{print $1}')

# Exports SMART info for each device
for device in $devices; do
    sudo smartctl -a "$device" | tee -a "$output_file" >/dev/null 2>&1
done

# Prints a conclusive message
echo "${green}SMART info has been exported. ${reset}"
