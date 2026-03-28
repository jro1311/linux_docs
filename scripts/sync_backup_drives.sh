#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

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

yellow_message "Note: /path/to/directory != /path/to/directory/"
read -er -p "Enter the path of the source backup drive (default: /run/media/linux_backup1/): " source_dir

# Define source directory
source_dir=${source_dir:-/run/media/linux_backup1/}
source_dir_used_space_bytes=$(df -B1 "$source_dir" | awk 'NR==2 {print $3}')
source_human=$(format_bytes "$source_dir_used_space_bytes")

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

green_message "Source (Used Space: $source_human): $source_dir"

read -er -p "Enter the path of the target backup drive (default: /run/media/linux_backup2): " target_dir

# Define target directory
target_dir=${target_dir:-/run/media/linux_backup2}
target_dir_total_space_bytes=$(df -B1 "$target_dir" | awk 'NR==2 {print $2}')
target_human=$(format_bytes "$target_dir_total_space_bytes")

# Validates directory
if [ ! -d "$target_dir" ]; then
    red_message "$target_dir does not exist."
    exit 1
fi

green_message "Target (Total Space: $target_human): $target_dir"

# Checks if backup drive has enough space
if [ "$target_dir_total_space_bytes" -lt "$source_dir_used_space_bytes" ]; then
    red_message "Insufficient Drive: $target_dir"
    exit 1
fi

read -r -p "Press enter to proceed, or ctrl+c to cancel: "

# Flushes all pending write operations on all disks
sync

# Syncs the source with the target and checks if it was successful
if rsync -auhvP --exclude='lost+found' --modify-window=1 "$source_dir" "$target_dir"; then
    green_message "Success: '$source_dir' synced with '$target_dir'"
else
    red_message "Error: '$source_dir' failed to sync with '$target_dir'"
    exit 1
fi

