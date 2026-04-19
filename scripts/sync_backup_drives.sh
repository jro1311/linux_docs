#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

# Exit on error, unset variable, or pipe failure
set -euo pipefail

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
read -er -p "Enter the path of the source backup drive (default: /run/media/linux_backup1/): " source_dir

source_dir=${source_dir:-/run/media/linux_backup1/}

if [ ! -d "$source_dir" ]; then
    red_message "Error:" "'$source_dir' does not exist."
    exit 1
fi

source_dir_used_space_bytes=$(df -B1 "$source_dir" | awk 'NR==2 {print $3}')
source_human=$(format_bytes "$source_dir_used_space_bytes")

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

target_dir=${target_dir:-/run/media/linux_backup2}

if [ ! -d "$target_dir" ]; then
    red_message "Error:" "'$target_dir' does not exist."
    exit 1
fi

target_dir_total_space_bytes=$(df -B1 "$target_dir" | awk 'NR==2 {print $2}')
target_human=$(format_bytes "$target_dir_total_space_bytes")

green_message "Target (Total Space: $target_human):" "$target_dir"

if [ "$target_dir_total_space_bytes" -lt "$source_dir_used_space_bytes" ]; then
    red_message "Insufficient Drive:" "$target_dir"
    exit 1
fi

sync_backup_drives() {
    local mode="$1"
    local sync_failed=0

    rsync_flags=(
        "-a"
        "-u"
        "-h"
        "-v"
        "-P"
        "--modify-window=1"
        "--exclude=lost+found/"
    )

    [ "$mode" = "dry" ] && rsync_flags+=( "--dry-run" )

    if sudo_run_passthrough rsync "${rsync_flags[@]}" "$source_dir" "$target_dir"; then
        green_message "Success:" "$target_dir"
    else
        red_message "Error:" "Failed to sync with '$target_dir'."
        sync_failed=1
    fi

    return "$sync_failed"
}

blue_message "MODE:" "DRY RUN (PREVIEW ONLY)"
sync_backup_drives "dry"

confirm_proceed

# Flushes pending writes
sync

blue_message "MODE:" "REAL RUN (APPLYING CHANGES)"
sync_backup_drives "real"
result=$?

if [ "$result" -eq 0 ]; then
    green_message "Success:" "'$source_dir' synced with '$target_dir'."
else
    red_message "Error:" "'$source_dir' failed to sync with '$target_dir'."
fi

exit "$result"

