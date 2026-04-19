#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Sources all .sh files in bashrc.d
shopt -s globstar nullglob

for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f "$rc" ]] && source "$rc"
done
unset rc

shopt -u globstar nullglob

read -er -p "Enter the path of the target directory (default: $HOME/Documents/): " target_dir
target_dir=${target_dir:-$HOME/Documents/}

# Normalizes user input so ~ and $HOME expand to absolute paths
target_dir="${target_dir/#~/$HOME}"
target_dir="${target_dir/#\$HOME/$HOME}"

if [ ! -d "$target_dir" ]; then
    red_message "Error:" "'$target_dir' does not exist."
    exit 1
fi

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
                mv -v "$file" "$new_name"
            fi
        fi
    done
}

if ask_for_confirmation "Run a dry run first?"; then
    snake_case_converter "dry"
fi

read -r -p "Press ${green}enter${reset} to proceed, or ${red}ctrl+c${reset} to cancel: "

if snake_case_converter "real"; then
    green_message "Success:" "Converted '$target_dir' to snake_case."
else
    red_message "Error:" "Failed to convert '$target_dir' to snake case."
fi
