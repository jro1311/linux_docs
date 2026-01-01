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

# Define source directory
source_dir="$HOME/Downloads/boot_images"

# Validates directory
if [ ! -d "$source_dir" ]; then
    echo "${red}$source_dir does not exist. ${reset}"
    exit 1
fi

# Checks that source directory is not empty
shopt -s nullglob
iso_files=( "$source_dir"/*.iso )
shopt -u nullglob

if (( ${#iso_files[@]} == 0 )); then
    echo "${red}$source_dir is empty. ${reset}"
    exit 1
fi

echo "${green}Source: $source_dir ${reset}"

target_dirs=(
    /run/media/linux_backup1/boot_images
    /run/media/linux_backup2/boot_images
    /run/media/josh/Ventoy/boot_images
)

# Flushes all pending write operations on all disks
sync

# Track if syncs were sucessfully
sync_success=false

# Syncs source directory to all target directories
for target in "${target_dirs[@]}"; do
    if rsync -auhvP --modify-window=1 --delete "$source_dir/" "$target/"; then
        echo "${green}Success: $target ${reset}"
        sync_success=true
    else
        echo "${red}Error: Failed to sync with '$target' ${reset}"
    fi
done

if [ "$sync_success" = true ]; then
    echo "${green}Success: '$source_dir' synced with all target directories. ${reset}"
else
    echo "${red}Error: Failed to sync '$source_dir' with all target directories. ${reset}"
    exit 1
fi
