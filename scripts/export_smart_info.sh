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

if ! ensure_pkg "smartmontools:smartctl"; then
    red_message "Error:" "Could not ensure package(s)."
    exit 1
fi

output_file="$HOME/Documents/smart_info/$(date +%Y-%m).txt"

if [ -f "$output_file" ]; then
    red_message "Error:" "'$output_file' already exists."
    exit 1
fi

devices=$(sudo smartctl --scan | awk '{print $1}')

for device in $devices; do
    if sudo smartctl -a "$device" | tee -a "$output_file" >/dev/null 2>&1; then
        green_message "Success:" "$device"
    else
        red_message "Failed:" "$device"
    fi
done

green_message "Success:" "Exported SMART info to '$output_file'."
