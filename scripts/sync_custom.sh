#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

packages=("rsync")
if ! command -v rsync >/dev/null 2>&1; then

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
            if ! command -v "${packages[@]}" >/dev/null 2>&1; then
                sudo rpm-ostree install "${packages[@]}"
                echo "${yellow}Reboot and run script again to complete. ${reset}"
                exit 0
            fi
            ;;
        *)
            echo "${red}Unsupported package manager. ${reset}"
            exit 1
            ;;
    esac
fi

echo "${yellow}Note: /path/to/directory != /path/to/directory/ ${reset}"
read -er -p "Enter the path of the source directory: " source_dir

# Expand ~ or $HOME to the full path
source_dir="${source_dir/#~/$HOME}"
source_dir="${source_dir/#\$HOME/$HOME}"

# Validates directory
if [ ! -d "$source_dir" ]; then
    echo "${red}$source_dir does not exist. ${reset}"
    exit 1
fi

echo "${green}Source: $source_dir ${reset}"

# Get list of mounted drives
mounted_drives=$(lsblk -o MOUNTPOINT -nr | grep -E '^(/run/media|/media|/mnt)')

# Enable nullglob so that the glob expands to nothing if no match
shopt -s nullglob

ask_for_confirmation() {
    local prompt="$1"
    local answer

    while true; do
        read -r -p "$prompt [y/N]: " answer
        answer="${answer:-n}"

        case "$answer" in
            [Yy]) return 0 ;;
            [Nn]) return 1 ;;
            *) echo "Enter a 'y' or 'n'." ;;
        esac
    done
}

if ask_for_confirmation "Run a dry run first?"; then

    # Loops through each mounted drive and syncs the directory
    sync_failed=0
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
        destination_dir="$drive/"

        # Syncs the source with the destination and checks if it was successful
        if rsync -auhvP --dry-run --modify-window=1 "$source_dir" "$destination_dir"; then
            echo "${green}Success: $destination_dir ${reset}"
        else
            echo "${red}Error: Failed to sync with '$destination_dir' ${reset}"
            sync_failed=1
        fi

    done

fi

read -r -p "Press enter to proceed, or ctrl+c to cancel: "

# Flushes all pending write operations on all disks
sync

# Loops through each mounted drive and syncs the directory
sync_failed=0
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
    destination_dir="$drive/"

    # Syncs the source with the destination and checks if it was successful
    if rsync -auhvP --modify-window=1 "$source_dir" "$destination_dir"; then
        echo "${green}Success: $destination_dir ${reset}"
    else
        echo "${red}Error: Failed to sync with '$destination_dir' ${reset}"
        sync_failed=1
    fi
    
done

if [ "$sync_failed" -eq 0 ]; then
    echo "${green}Success: '$source_dir' synced with all mounted drives. ${reset}"
else
    echo "${red}Error: Failed to sync '$source_dir' with all mounted drives. ${reset}"
    exit 1
fi
