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
read -er -p "Enter the path of the source directory: " source_dir

# Expand ~ or $HOME to the full path
source_dir="${source_dir/#~/$HOME}"
source_dir="${source_dir/#\$HOME/$HOME}"

source_dir_size_bytes=$(du -sb "$source_dir" | awk '{print $1}')
source_human=$(format_bytes "$source_dir_size_bytes")

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

echo "${green}Source (Size: $source_human): $source_dir ${reset}"

# Get list of mounted drives
mounted_drives=$(lsblk -o MOUNTPOINT -nr | grep -E '^(/run/media|/media|/mnt)')

skipped_drives=()

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
    for mount_dir in $mounted_drives; do

        # Skips if parent directory is not a mountpoint
        if ! mountpoint -q "$mount_dir"; then
            echo "${yellow}Skipped Unmounted Drive: $mount_dir ${reset}"
            continue
        fi

        # Skips Ventoy drives
        if [[ "$mount_dir" = "/run/media/${USER}/Ventoy"* ]]; then
            echo "${yellow}Skipped Ventoy Drive: $mount_dir ${reset}"
            continue
        fi

        # Skips Ventoy EFI partitions
        if [[ "$mount_dir" = "/run/media/${USER}/VTOYEFI"* ]]; then
            echo "${yellow}Skipped Ventoy Drive: $mount_dir ${reset}"
            continue
        fi

        free_space_bytes=$(df -B1 "$mount_dir" | awk 'NR==2 {print $4}')

        # Skips if drive has insufficient free space
        if [ "$free_space_bytes" -lt "$source_dir_size_bytes" ]; then
            echo "${yellow}Skipped Insufficient Drive: $mount_dir ${reset}"
            continue
        fi

        target_dir="$mount_dir/"

        if rsync -auhvP --dry-run --modify-window=1 "$source_dir" "$target_dir"; then
            echo "${green}Success: $target_dir ${reset}"
        else
            echo "${red}Error: Failed to sync with '$target_dir' ${reset}"
            sync_failed=1
        fi

    done

    # Prints skipped drives at the bottom
    if [ "${#skipped_drives[@]}" -gt 0 ]; then
        for msg in "${skipped_drives[@]}"; do
            echo "$msg"
        done
    fi

fi

read -r -p "Press enter to proceed, or ctrl+c to cancel: "

# Flushes all pending write operations on all disks
sync

# Loops through each mounted drive and syncs the directory
sync_failed=0
for mount_dir in $mounted_drives; do

    # Skips if parent directory is not a mountpoint
    if ! mountpoint -q "$mount_dir"; then
        skipped_drives+=( "${yellow}Skipped (Unmounted Drive): $mount_dir ${reset}" )
        continue
    fi

    # Skips Ventoy drives
    if [[ "$mount_dir" = "/run/media/${USER}/Ventoy"* ]]; then
        skipped_drives+=( "${yellow}Skipped (Ventoy Drive): $mount_dir ${reset}" )
        continue
    fi

    # Skips Ventoy EFI partitions
    if [[ "$mount_dir" = "/run/media/${USER}/VTOYEFI"* ]]; then
        skipped_drives+=( "${yellow}Skipped (Ventoy EFI Partition): $mount_dir ${reset}" )
        continue
    fi

    free_space_bytes=$(df -B1 "$mount_dir" | awk 'NR==2 {print $4}')

    # Skips if drive has insufficient free space
    if [ "$free_space_bytes" -lt "$source_dir_size_bytes" ]; then
        skipped_drives+=( "${yellow}Skipped (Insufficient Drive): $mount_dir ${reset}" )
        continue
    fi

    target_dir="$mount_dir/"

    if rsync -auhvP --modify-window=1 "$source_dir" "$target_dir"; then
        echo "${green}Success: $target_dir ${reset}"
    else
        echo "${red}Error: Failed to sync with '$target_dir' ${reset}"
        sync_failed=1
    fi
    
done

# Prints skipped drives
if [ "${#skipped_drives[@]}" -gt 0 ]; then
    for msg in "${skipped_drives[@]}"; do
        echo "$msg"
    done
fi

if [ "$sync_failed" -eq 0 ]; then
    echo "${green}Success: '$source_dir' synced with all valid drives. ${reset}"
else
    echo "${red}Error: Failed to sync '$source_dir' with all valid drives. ${reset}"
    exit 1
fi
