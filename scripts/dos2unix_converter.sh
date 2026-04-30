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

if ! ensure_pkg "dos2unix"; then
    red_message "Error:" "Could not ensure package(s)."
    exit 1
fi

target_dir=$(input_directory "Enter target directory (default: $HOME/Documents)" "$HOME/Documents")
green_message "Target:" "$target_dir"

confirm_proceed

conversion_failed=0
all_files=()
collect_text_files "$target_dir" all_files

for file in "${all_files[@]}"; do
    if ! dos2unix "$file" >/dev/null 2>&1; then
        red_message "Error:" "Failed to convert '$file'."
        conversion_failed=1
    fi
done

if [ "$conversion_failed" -eq 0 ]; then
    green_message "Success:" "$target_dir"
else
    red_message "Failure:" "$target_dir"
    exit 1
fi
