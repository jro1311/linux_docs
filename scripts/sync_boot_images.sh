#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Sources all .sh files in $HOME/Documents/linux_docs/configs/system/bash/bashrc.d
shopt -s globstar nullglob

# shellcheck source=/dev/null
for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f $rc ]] && source "$rc"
done
unset rc

shopt -u globstar nullglob

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
        green_message "Primary Package Manager: $primary_package_manager"
    fi

    packages=("rsync")
    install_packages "${packages[@]}"

fi

# Define source directory
source_dir="$HOME/Downloads/boot_images"
source_dir_size_bytes=$(du -sb "$source_dir" | awk '{print $1}')
source_human=$(format_bytes "$source_dir_size_bytes")

# Validates directory
if [ ! -d "$source_dir" ]; then
    red_message "$source_dir does not exist."
    exit 1
fi

# Checks that source directory is not empty
shopt -s nullglob
files=( "$source_dir"/* )
shopt -u nullglob

if (( ${#files[@]} == 0 )); then
    red_message "$source_dir is empty."
    exit 1
fi

green_message "Source (Size: $source_human): $source_dir"

# Get list of mounted drives
mounted_drives=$(lsblk -o MOUNTPOINT -nr | grep -E '^(/run/media|/media|/mnt)')

skipped_drives=()

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

    # Skips Ventoy EFI partitions
    if [[ "$mount_dir" = "/run/media/${USER}/VTOYEFI"* ]]; then
        skipped_drives+=( "${yellow}Skipped (Ventoy EFI Partition): $mount_dir ${reset}" )
        continue
    fi

    free_space_bytes=$(df -B1 "$mount_dir" | awk 'NR==2 {print $4}')

    # Skip if drive has insufficient free space
    if [ "$free_space_bytes" -lt "$source_dir_size_bytes" ]; then
        skipped_drives+=( "${yellow}Skipped (Insufficient Drive): $mount_dir ${reset}" )
        continue
    fi

    target_dir="$mount_dir/boot_images"

    # Skips if boot_images directory does not exist
    if [[ ! -d "$target_dir" ]]; then
        skipped_drives+=( "${yellow}Skipped (Missing Directory): $target_dir ${reset}" )
        continue
    fi

    if rsync -auhvP --modify-window=1 --delete "$source_dir/" "$target_dir/"; then
        green_message "Success: $target_dir"
    else
        red_message "Error: Failed to sync with '$target_dir'"
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
    green_message "Success: '$source_dir' synced with all valid drives."
else
    red_message "Error: Failed to sync '$source_dir' with all valid drives."
    exit 1
fi
