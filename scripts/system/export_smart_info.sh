#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

ld_bash_dir="$HOME/Documents/linux_docs/configs/system/bash/bash.d"

shopt -s nullglob globstar
for file in "$ld_bash_dir"/**/*.sh; do
    [ -e "$file" ] || continue
    . "$file"
done
shopt -u nullglob globstar

ensure_pkg "smartmontools"

output_file="$HOME/Documents/smart_info/$(date +%Y-%m).txt"

if [ -f "$output_file" ]; then
    red_message "Error:" "'$output_file' already exists."
    exit 1
fi

devices=$(sudo smartctl --scan | awk '{print $1}')

for device in $devices; do
    if sudo smartctl -a "$device" | tee -a "$output_file" >/dev/null; then
        green_message "Success:" "$device"
    else
        red_message "Failed:" "$device"
    fi
done

green_message "Success:" "Exported SMART info to '$output_file'."
