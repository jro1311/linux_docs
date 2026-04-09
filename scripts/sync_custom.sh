#!/usr/bin/env bash
# shellcheck disable=SC2154

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
yellow=$(tput setaf 3)
reset=$(tput sgr0)

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
read -er -p "Enter the path of the source directory: " source_dir

# Expand ~ or $HOME to the full path
source_dir="${source_dir/#~/$HOME}"
source_dir="${source_dir/#\$HOME/$HOME}"

# Validates directory
if [ ! -d "$source_dir" ]; then
    red_message "Error:" "'$source_dir' does not exist."
    exit 1
fi

source_dir_size_bytes=$(du -sb "$source_dir" | awk '{print $1}')
source_human=$(format_bytes "$source_dir_size_bytes")

# Checks that source directory is not empty
shopt -s nullglob
files=( "$source_dir"/* )
shopt -u nullglob

if (( ${#files[@]} == 0 )); then
    red_message "$source_dir is empty."
    exit 1
fi

green_message "Source (Size: $source_human):" "$source_dir"

# Get list of mounted drives
mounted_drives=$(lsblk -o MOUNTPOINT -nr | grep -E '^(/run/media|/media|/mnt)')
skipped_drives=()

# Enable nullglob so that the glob expands to nothing if no match
shopt -s nullglob

# Prompts the user to run a dry run
if ask_for_confirmation "Run a dry run first?"; then

    sync_failed=0
    for mount_dir in $mounted_drives; do

        # Skips if parent directory is not a mountpoint
        if ! mountpoint -q "$mount_dir"; then
            skipped_drives+=( "${yellow}Skipped (Unmounted Drive):${reset} $mount_dir" )
            continue
        fi

        # Skips Ventoy drives
        if [[ "$mount_dir" = "/run/media/${USER}/Ventoy"* ]]; then
            skipped_drives+=( "${yellow}Skipped (Ventoy Drive):${reset} $mount_dir" )
            continue
        fi

        # Skips Ventoy EFI partitions
        if [[ "$mount_dir" = "/run/media/${USER}/VTOYEFI"* ]]; then
            skipped_drives+=( "${yellow}Skipped (Ventoy EFI Partition):${reset} $mount_dir" )
            continue
        fi

        free_space_bytes=$(df -B1 "$mount_dir" | awk 'NR==2 {print $4}')

        # Skips if drive has insufficient free space
        if [ "$free_space_bytes" -lt "$source_dir_size_bytes" ]; then
            skipped_drives+=( "${yellow}Skipped (Insufficient Drive):${reset} $mount_dir" )
            continue
        fi

        target_dir="$mount_dir/"

        if sudo_run_passthrough rsync -auhvP --dry-run --modify-window=1 "$source_dir" "$target_dir"; then
            green_message "Success:" "$target_dir"
        else
            red_message "Error:" "Failed to sync with '$target_dir'."
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

skipped_drives=()
read -r -p "Press ${green}enter${reset} to proceed, or ${red}ctrl+c${reset} to cancel: "

# Flushes all pending write operations on all disks
sync

# Loops through each mounted drive and syncs the directory
sync_failed=0
for mount_dir in $mounted_drives; do

    # Skips if parent directory is not a mountpoint
    if ! mountpoint -q "$mount_dir"; then
        skipped_drives+=( "${yellow}Skipped (Unmounted Drive):${reset} $mount_dir" )
        continue
    fi

    # Skips Ventoy drives
    if [[ "$mount_dir" = "/run/media/${USER}/Ventoy"* ]]; then
        skipped_drives+=( "${yellow}Skipped (Ventoy Drive):${reset} $mount_dir" )
        continue
    fi

    # Skips Ventoy EFI partitions
    if [[ "$mount_dir" = "/run/media/${USER}/VTOYEFI"* ]]; then
        skipped_drives+=( "${yellow}Skipped (Ventoy EFI Partition):${reset} $mount_dir" )
        continue
    fi

    free_space_bytes=$(df -B1 "$mount_dir" | awk 'NR==2 {print $4}')

    # Skips if drive has insufficient free space
    if [ "$free_space_bytes" -lt "$source_dir_size_bytes" ]; then
        skipped_drives+=( "${yellow}Skipped (Insufficient Drive):${reset} $mount_dir" )
        continue
    fi

    target_dir="$mount_dir/"

    if sudo_run_passthrough rsync -auhvP --modify-window=1 "$source_dir" "$target_dir"; then
        green_message "Success:" "$target_dir"
    else
        red_message "Error:" "Failed to sync with '$target_dir'."
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
    green_message "Success:" "'$source_dir' synced with all valid drives."
else
    red_message "Error:" "Failed to sync '$source_dir' with all valid drives."
    exit 1
fi
