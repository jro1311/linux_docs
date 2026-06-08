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

ensure_pkg "dos2unix"

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
