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
cd "$target_dir"

snake_case_converter() {
    local mode="$1"

    for file in *; do
        new_name=$(printf '%s' "$file" \
            | tr '[:upper:]' '[:lower:]' \
            | sed 's/[[:space:]-]/_/g; s/__*/_/g')

        if [ "$mode" = "dry" ]; then
            printf "'%s' -> '%s'\n" "$file" "$new_name"
        else
            if [ "$file" != "$new_name" ]; then
                mv "$file" "$new_name"
            fi
        fi
    done
}

blue_message "MODE:" "DRY RUN (PREVIEW ONLY)"
snake_case_converter "dry"

confirm_proceed

blue_message "MODE:" "REAL RUN (APPLYING CHANGES)"
if snake_case_converter "real"; then
    green_message "Success:" "$target_dir"
else
    red_message "Failure:" "$target_dir"
    exit 1
fi
