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
packages=("rsync")
for package in "${packages[@]}"; do
    inverse_check "$package" \
        install_packages "$package"
done

yellow_message "Note:" "/path/to/directory != /path/to/directory/"
read -er -p "Enter the path of the source backup drive (default: /run/media/linux_backup1/): " source_dir

# Define source directory
source_dir=${source_dir:-/run/media/linux_backup1/}
source_dir_used_space_bytes=$(df -B1 "$source_dir" | awk 'NR==2 {print $3}')
source_human=$(format_bytes "$source_dir_used_space_bytes")

# Validates directory
if [ ! -d "$source_dir" ]; then
    red_message "Error:" "'$source_dir' does not exist."
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

green_message "Source (Used Space: $source_human):" "$source_dir"
read -er -p "Enter the path of the target backup drive (default: /run/media/linux_backup2): " target_dir

# Define target directory
target_dir=${target_dir:-/run/media/linux_backup2}
target_dir_total_space_bytes=$(df -B1 "$target_dir" | awk 'NR==2 {print $2}')
target_human=$(format_bytes "$target_dir_total_space_bytes")

# Validates directory
if [ ! -d "$target_dir" ]; then
    red_message "Error:" "'$target_dir' does not exist."
    exit 1
fi

green_message "Target (Total Space: $target_human):" "$target_dir"

# Checks if backup drive has enough space
if [ "$target_dir_total_space_bytes" -lt "$source_dir_used_space_bytes" ]; then
    red_message "Insufficient Drive:" "$target_dir"
    exit 1
fi

# Prompts the user to run a dry run
if ask_for_confirmation "Run a dry run first?"; then
    if sudo_run_passthrough rsync -auhvP --exclude='lost+found' --modify-window=1 --dry-run "$source_dir" "$target_dir"; then
        green_message "Success:" "'$source_dir' synced with '$target_dir'."
    else
        red_message "Error:" "'$source_dir' failed to sync with '$target_dir'."
        exit 1
    fi
fi

read -r -p "Press enter to proceed, or ctrl+c to cancel: "

# Flushes all pending write operations on all disks
sync

# Syncs the source with the target and checks if it was successful
if sudo_run_passthrough rsync -auhvP --exclude='lost+found' --modify-window=1 "$source_dir" "$target_dir"; then
    green_message "Success:" "'$source_dir' synced with '$target_dir'."
else
    red_message "Error:" "'$source_dir' failed to sync with '$target_dir'."
    exit 1
fi

