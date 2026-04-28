#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# shellcheck disable=SC2044
# Sources all .sh files in bashrc.d
for rc in $(find "$HOME/Documents/linux_docs/configs/system/bash/bashrc.d" -type f -name '*.sh' 2>/dev/null); do
    . "$rc"
done

ensure_pkg "rsync"

info_trailing_slash_mismatch

source_drive=$(input_directory "Enter source drive (default: /run/media/linux_backup1/)" "/run/media/linux_backup1/")
source_drive_used_space_bytes=$(df -B1 "$source_drive" | awk 'NR==2 {print $3}')
source_human=$(format_bytes "$source_drive_used_space_bytes")

set -- "$source_drive"/*
if [ ! -e "$1" ]; then
    red_message "Error" "'$source_drive' is empty."
    exit 1
fi

target_drive=$(input_directory "Enter target drive (default: /run/media/linux_backup2)" "/run/media/linux_backup2")
target_drive_total_space_bytes=$(df -B1 "$target_drive" | awk 'NR==2 {print $2}')
target_human=$(format_bytes "$target_drive_total_space_bytes")

green_message "Source (Used Space: $source_human):" "$source_drive"
green_message "Target (Total Space: $target_human):" "$target_drive"

if [ "$target_drive_total_space_bytes" -lt "$source_drive_used_space_bytes" ]; then
    red_message "Error (Insufficient Drive):" "$target_drive"
    exit 1
fi

sync_backup_drives() {
    local mode="$1"
    rsync_flags=(
        "-a"
        "-u"
        "-h"
        "-v"
        "-P"
        "--modify-window=1"
        "--delete"
        "--exclude=lost+found/"
        "--exclude=.Trash-*/"
    )

    [ "$mode" = "dry" ] && rsync_flags+=( "--dry-run" )

    if sudo_run_passthrough rsync "${rsync_flags[@]}" "$source_drive" "$target_drive"; then
        green_message "Success:" "$target_drive"
    else
        red_message "Failure:" "'$target_drive'"
    fi
}

blue_message "MODE:" "DRY RUN (PREVIEW ONLY)"
sync_backup_drives "dry"

confirm_proceed

# Flushes pending writes
sync

blue_message "MODE:" "REAL RUN (APPLYING CHANGES)"
sync_backup_drives "real"

