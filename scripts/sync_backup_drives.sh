#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

bashd_dir="$HOME/Documents/linux_docs/configs/system/bash/bashrc.d"

for file in "$bashd_dir"/*.sh; do
    [ -e "$file" ] || continue
    . "$file"
done

for dir in helpers configure_packages install_packages; do
    for file in "$bashd_dir/$dir"/*.sh; do
        [ -e "$file" ] || continue
        . "$file"
    done
done

if ! ensure_pkg "rsync"; then
    red_message "Error:" "Could not ensure package(s)."
    exit 1
fi

source_drive=""
source_drive_total_space_bytes=""
source_drive_used_space_bytes=""
source_total_human=""
source_used_human=""

target_drive=""
target_drive_total_space_bytes=""
target_drive_used_space_bytes=""
target_total_human=""
target_used_human=""

green_message "Drives:"
printf '%s\n' \
    "[1] linux_backup1 + linux_backup2" \
    "[2] custom" \
    "[x] cancel" \
    | sed "s/^/  /" >&2

while true; do
    read -r -p "Select drive option [1-2]: " num

    case "$num" in
        1)
            source_drive="/run/media/linux_backup1"
            target_drive="/run/media/linux_backup2"
            ;;
        2)
            source_drive=$(input_directory "Enter source drive")
            target_drive=$(input_directory "Enter target drive")

            case "$source_drive" in
                "$HOME"|"$HOME"/*)
                    red_message "Error:" "Home directory paths are not allowed."
                    continue
                    ;;
            esac

            case "$target_drive" in
                "$HOME"|"$HOME"/*)
                    red_message "Error:" "Home directory paths are not allowed."
                    continue
                    ;;
            esac
            ;;
        x) exit 0 ;;
        *) continue ;;
    esac

    break
done

set -- "$source_drive"/*
if [ ! -e "$1" ]; then
    red_message "Error" "'$source_drive' is empty."
    exit 1
fi

source_drive_total_space_bytes=$(df -B1 "$source_drive" | awk 'NR==2 {print $2}')
source_drive_used_space_bytes=$(df -B1 "$source_drive" | awk 'NR==2 {print $3}')

source_total_human=$(format_bytes "$source_drive_total_space_bytes")
source_used_human=$(format_bytes "$source_drive_used_space_bytes")

target_drive_total_space_bytes=$(df -B1 "$target_drive" | awk 'NR==2 {print $2}')
target_drive_used_space_bytes=$(df -B1 "$target_drive" | awk 'NR==2 {print $3}')

target_used_human=$(format_bytes "$target_drive_used_space_bytes")
target_total_human=$(format_bytes "$target_drive_total_space_bytes")

green_message "Source ($source_used_human / $source_total_human):" "$source_drive"
green_message "Target ($target_used_human / $target_total_human):" "$target_drive"

if [ "$target_drive_total_space_bytes" -lt "$source_drive_used_space_bytes" ]; then
    red_message "Error (Insufficient Drive):" "$target_drive"
    exit 1
fi

sync_backup_drives() {
    local mode="$1"

    rsync_flags=(
        -a
        -u
        -h
        -v
        -P
        --modify-window=1
        --delete
        --exclude=lost+found/
        "--exclude=.Trash-*/"
    )

    [ "$mode" = "dry" ] && rsync_flags+=( "--dry-run" )

    if sudo_run_passthrough rsync "${rsync_flags[@]}" "$source_drive/" "$target_drive"; then
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

