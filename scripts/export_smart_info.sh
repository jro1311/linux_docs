#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

. "$HOME/Documents/linux_docs/configs/system/bash/bashrc.d/helpers/source.sh"
source_all "$HOME/Documents/linux_docs/configs/system/bash/bashrc.d"

ensure_pkg "smartmontools:smartctl"

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
