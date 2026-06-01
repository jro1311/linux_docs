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

target_dir=$(input_directory "Enter target directory (default: $HOME/Documents)" "$HOME/Documents")
green_message "Target:" "$target_dir"

while true; do
    read -r -p "Enter text: " text

    if [ -z "$text" ]; then
        red_message "Error:" "No text provided."
        exit 1
    fi

    text_found=0
    all_files=()
    collect_text_files "$target_dir" all_files

    for file in "${all_files[@]}"; do
        if matches=$(grep -Fn -- "$text" "$file"); then
            green_message "FILE:" "$file"
            printf "%s\n" "$matches" | sed "s/^/  /"
            printf '\n'
            text_found=1
        fi
    done

    if [ "$text_found" -eq 0 ]; then
        yellow_message "No matches found:" "'$text' was not found in '$target_dir'."
    fi

    confirm "Continue? [y/N]" || break
done
