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
cd "$target_dir"

snake_case_converter() {
    local mode="$1"
    local file new_name

    for file in *; do
        new_name=$(printf '%s' "$file" \
            | tr '[:upper:]' '[:lower:]' \
            | sed 's/[[:space:]-]/_/g; s/__*/_/g')

        if [ "$file" != "$new_name" ]; then
            if [ "$mode" = "dry" ]; then
                printf "'%s' -> '%s'\n" "$file" "$new_name"
            else
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
