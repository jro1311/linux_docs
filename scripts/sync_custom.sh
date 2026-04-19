#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Defines color variables using tput
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Sources all .sh files in bashrc.d
shopt -s globstar nullglob

for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f "$rc" ]] && source "$rc"
done
unset rc

shopt -u globstar nullglob

# Installs missing packages
packages=("rsync")
for package in "${packages[@]}"; do
    inverse_check "$package" \
        install_packages "$package"
done

yellow_message "Note:" "/path/to/directory != /path/to/directory/"
read -er -p "Enter the path of the source directory: " source_dir

# Normalizes user input so ~ and $HOME expand to absolute paths
source_dir="${source_dir/#~/$HOME}"
source_dir="${source_dir/#\$HOME/$HOME}"

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

sync_mounted_drives() {
    local mode="$1"
    local sync_failed=0
    skipped_drives=()

    for mount_dir in $mounted_drives; do

        # Skips drives that are not mounted
        if ! mountpoint -q "$mount_dir"; then
            skipped_drives+=( "${yellow}Skipped (Unmounted Drive):${reset} $mount_dir" )
            continue
        fi

        # Skips Ventoy data partitions
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

        # Skips drives that cannot hold the source directory
        if [ "$free_space_bytes" -lt "$source_dir_size_bytes" ]; then
            skipped_drives+=( "${yellow}Skipped (Insufficient Drive):${reset} $mount_dir" )
            continue
        fi

        target_dir="$mount_dir/"

        rsync_flags=(
            "-a"
            "-u"
            "-h"
            "-v"
            "-P"
            "--modify-window=1"
        )

        [ "$mode" = "dry" ] && rsync_flags+=( "--dry-run" )

        if sudo_run_passthrough rsync "${rsync_flags[@]}" "$source_dir" "$target_dir"; then
            green_message "Success:" "$target_dir"
        else
            red_message "Error:" "Failed to sync with '$target_dir'."
            sync_failed=1
        fi

    done

    if [ "${#skipped_drives[@]}" -gt 0 ]; then
        printf '%s\n' "${skipped_drives[@]}"
    fi

    return "$sync_failed"
}

mounted_drives=$(lsblk -o MOUNTPOINT -nr | grep -E '^(/run/media|/media|/mnt)')
shopt -s nullglob

if ask_for_confirmation "Run a dry run first?"; then
    sync_mounted_drives "dry"
fi

read -r -p "Press ${green}enter${reset} to proceed, or ${red}ctrl+c${reset} to cancel: "

# Flushes pending writes
sync

sync_mounted_drives "real"
result=$?

if [ "$result" -eq 0 ]; then
    green_message "Success:" "'$source_dir' synced with all valid drives."
else
    red_message "Error:" "Failed to sync '$source_dir' with all valid drives."
fi

exit "$result"
