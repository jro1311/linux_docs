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

target_dir=$(input_directory "Enter target directory (default: $HOME/Documents)" "$HOME/Documents")
green_message "Target:" "$target_dir"

read -er -p "Enter text: " text

if [ -z "$text" ]; then
    red_message "Error:" "No text provided."
    exit 1
fi

text_found=0
all_files=()
collect_text_files "$target_dir" all_files

for file in "${all_files[@]}"; do
    if grep -Fq -- "$text" "$file"; then
        green_message "FILE:" "$file"
        grep -Fn -- "$text" "$file" | sed "s/^/  /"
        printf '\n'
        text_found=1
    fi
done

if [ "$text_found" -eq 0 ]; then
    yellow_message "No matches found:" "'$text' was not found in '$target_dir'."
fi
