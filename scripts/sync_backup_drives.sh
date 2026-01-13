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

format_bytes() {
    bytes=$1

    if [ "$bytes" -ge $((1024*1024*1024)) ]; then
        value=$(awk "BEGIN { printf \"%.1f\", $bytes / (1024*1024*1024) }")
        units="GiB"

    elif [ "$bytes" -ge $((1024*1024)) ]; then
        value=$(awk "BEGIN { printf \"%.1f\", $bytes / (1024*1024) }")
        units="MiB"

    else
        value=$(awk "BEGIN { printf \"%.1f\", $bytes / 1024 }")
        units="KiB"
    fi

    printf "%s %s" "$value" "$units"
}

echo "${yellow}Note: /path/to/directory != /path/to/directory/ ${reset}"
read -er -p "Enter the path of the source backup drive (default: /run/media/linux_backup1/): " source_dir

# Define source directory
source_dir=${source_dir:-/run/media/linux_backup1/}
source_dir_used_space_bytes=$(du -sb "$source_dir" | awk '{print $1}')
source_human=$(format_bytes "$source_dir_used_space_bytes")

# Validates directory
if [ ! -d "$source_dir" ]; then
    echo "${red}$source_dir does not exist. ${reset}"
    exit 1
fi

# Checks that source directory is not empty
shopt -s nullglob
files=( "$source_dir"/* )
shopt -u nullglob

if (( ${#files[@]} == 0 )); then
    echo "${red}$source_dir is empty. ${reset}"
    exit 1
fi

echo "${green}Source (Used Space: $source_human): $source_dir ${reset}"

read -er -p "Enter the path of the target backup drive (default: /run/media/linux_backup2): " target_dir

# Define target directory
target_dir=${target_dir:-/run/media/linux_backup2}
target_dir_total_space_bytes=$(df -B1 "$target_dir" | awk 'NR==2 {print $2}')
target_human=$(format_bytes "$target_dir_total_space_bytes")

# Validates directory
if [ ! -d "$target_dir" ]; then
    echo "${red}$target_dir does not exist. ${reset}"
    exit 1
fi

echo "${green}Target (Total Space: $target_human): $target_dir ${reset}"

# Checks if backup drive has enough space
if [ "$target_dir_total_space_bytes" -lt "$source_dir_used_space_bytes" ]; then
    echo "${red}Insufficient Drive: $target_dir ${reset}"
    exit 1
fi

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
    rsync -auhvP --dry-run --exclude='lost+found' --modify-window=1 "$source_dir" "$target_dir"
fi

read -r -p "Press enter to proceed, or ctrl+c to cancel: "

# Flushes all pending write operations on all disks
sync

# Syncs the source with the target and checks if it was successful
if rsync -auhvP --exclude='lost+found' --modify-window=1 "$source_dir" "$target_dir"; then
    echo "${green}Success: '$source_dir' synced with '$target_dir' ${reset}"
else
    echo "${red}Error: '$source_dir' failed to sync with '$target_dir' ${reset}"
    exit 1
fi

