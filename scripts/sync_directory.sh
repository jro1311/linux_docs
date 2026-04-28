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

if command -v tput &>/dev/null; then
    yellow=$(tput setaf 3)
    reset=$(tput sgr0)
else
    yellow=$'\033[33m'
    reset=$'\033[0m'
fi

ensure_pkg "rsync"

source_dir=""

green_message "Directories:"
printf '%s\n' \
    "[1] linux_docs" \
    "[2] boot_images" \
    "[3] personal" \
    "[4] custom" \
    "[x] cancel" | sed "s/^/  /"

while true; do
    read -r -p "Select directory [1-4]: " num

    case "$num" in
        1) source_dir="$HOME/Documents/linux_docs" ;;
        2) source_dir="$HOME/Downloads/boot_images" ;;
        3) source_dir="$HOME/Documents/personal" ;;
        4)
            info_trailing_slash_mismatch
            source_dir=$(input_directory "Enter source directory")
            ;;
        x) exit 0 ;;
        *) continue ;;
    esac

    break
done

if [ ! -d "$source_dir" ]; then
    red_message "Error:" "'$source_dir' does not exist."
    exit 1
fi

set -- "$source_dir"/*
if [ ! -e "$1" ]; then
    red_message "Error" "'$source_dir' is empty."
    exit 1
fi

source_dir_size_bytes=$(du -sb "$source_dir" | awk '{print $1}')
source_human=$(format_bytes "$source_dir_size_bytes")

green_message "Source (Size: $source_human):" "$source_dir"

sync_mounted_drives() {
    local mode="$1"
    skipped_drives=()

    for mount_dir in $mounted_drives; do

        # Skips drives that are not mounted
        if ! mountpoint -q "$mount_dir"; then
            skipped_drives+=( "${yellow}Skipped (Unmounted Drive):${reset} $mount_dir" )
            continue
        fi

        # Skips Ventoy data partitions
        case "$source_dir" in
            "$HOME/Downloads/boot_images")
                ;;
            *)
                if [[ "$mount_dir" = "/run/media/$USER/Ventoy"* ]]; then
                    skipped_drives+=( "${yellow}Skipped (Ventoy Drive):${reset} $mount_dir" )
                    continue
                fi
                ;;
        esac

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

        rsync_flags=(
            "-a"
            "-u"
            "-h"
            "-v"
            "-P"
            "--modify-window=1"
        )

        case "$source_dir" in
            "$HOME/Documents/linux_docs")
                target_dir="$mount_dir/linux_docs"

                rsync_flags+=(
                    "--delete"
                    "--exclude=.git/"
                )
                ;;
            "$HOME/Downloads/boot_images")
                target_dir="$mount_dir/boot_images"

                rsync_flags+=(
                    "--delete"
                )
                ;;
            *)
                target_dir="$mount_dir/$(basename "$source_dir")"
        esac

        [ "$mode" = "dry" ] && rsync_flags+=( "--dry-run" )

        if sudo_run_passthrough rsync "${rsync_flags[@]}" "$source_dir/" "$target_dir/"; then
            green_message "Success:" "'$target_dir'"
        else
            red_message "Failure:" "'$target_dir'"
        fi

    done

    if [ "${#skipped_drives[@]}" -gt 0 ]; then
        printf '%s\n' "${skipped_drives[@]}"
    fi
}

mounted_drives=$(lsblk -o MOUNTPOINT -nr | grep -E '^(/run/media|/media|/mnt)')
shopt -s nullglob

blue_message "MODE:" "DRY RUN (PREVIEW ONLY)"
sync_mounted_drives "dry"

confirm_proceed

# Flushes pending writes
sync

blue_message "MODE:" "REAL RUN (APPLYING CHANGES)"
sync_mounted_drives "real"
