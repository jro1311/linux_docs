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

target_dir=$(input_directory "Enter target directory (default: $HOME/Documents)" "$HOME/Documents")
green_message "Target:" "$target_dir"

read -r -p "Enter text: " text

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
