#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# List of packages
packages=("rsync")

# Checks for package
if ! command -v rsync > /dev/null 2>&1; then

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

# Source directory
source="$HOME/Documents/linux_docs"

# Checks for directory
if [ ! -d "$source" ]; then
    echo "${red}$source does not exist. ${reset}"
    exit 1
fi

# Prints source directory
echo "${green}Source: $source ${reset}"

# Flushes all pending write operations on all disks
sync

# Get list of mounted drives
mounted_drives=$(lsblk -o MOUNTPOINT -nr | grep -E '^(/run/media|/media|/mnt)')

# Track if syncs were sucessfully
sync_success=false

# Enable nullglob so that the glob expands to nothing if no match
shopt -s nullglob

# Loops through each mounted drive and syncs the directory
for drive in $mounted_drives; do

    # Skips Ventoy drives
    if [[ "$drive" = "/run/media/${USER}/Ventoy"* ]]; then
        echo "${yellow}Skipped Ventoy Drive: $drive ${reset}"
        continue
    fi
    
    # Skips Ventoy EFI partitions
    if [[ "$drive" = "/run/media/${USER}/VTOYEFI"* ]]; then
        echo "${yellow}Skipped Ventoy Drive: $drive ${reset}"
        continue
    fi

    # Create the destination path
    destination="$drive/"

    # Syncs the source with the destination and checks if it was successful
    if rsync -auhvP --modify-window=1 --delete "$source" "$destination"; then
        echo "${green}Success: $destination ${reset}"
        sync_success=true
    else
        echo "${red}Error: Failed to sync with '$destination' ${reset}"
    fi
    
done

# Prints a conclusive message
if [ "$sync_success" = true ]; then
    echo "${green}Success: '$source' synced with all mounted drives. ${reset}"
else
    echo "${red}Error: Failed to sync '$source' with all mounted drives. ${reset}"
fi
