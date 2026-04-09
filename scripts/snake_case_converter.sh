#!/usr/bin/env bash
# shellcheck disable=SC2154

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Sources all .sh files in $HOME/Documents/linux_docs/configs/system/bash/bashrc.d
shopt -s globstar nullglob

# shellcheck source=/dev/null
for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f "$rc" ]] && source "$rc"
done
unset rc
shopt -u globstar nullglob

# Prompts for target directory (default: $HOME/Documents)
read -er -p "Enter the path of the target directory (default: $HOME/Documents/): " target_dir
target_dir=${target_dir:-$HOME/Documents/}

# Expand ~ or $HOME to the full path
target_dir="${target_dir/#~/$HOME}"
target_dir="${target_dir/#\$HOME/$HOME}"

# Validates directory
if [ ! -d "$target_dir" ]; then
    red_message "Error:" "'$target_dir' does not exist."
    exit 1
fi

green_message "Target:" "$target_dir"
cd "$target_dir"

if ask_for_confirmation "Run a dry run first?"; then
    for file in *; do
        new_name=$(printf '%s' "$file" \
            | tr '[:upper:]' '[:lower:]' \
            | sed 's/[[:space:]-]/_/g; s/__*/_/g')

        if [ "$file" != "$new_name" ]; then
            printf "'%q' -> '%q'\n" "$file" "$new_name"
        fi
    done
fi

read -r -p "Press ${green}enter${reset} to proceed, or ${red}ctrl+c${reset} to cancel: "

# Convert filenames to snake_case (non-recursive)
for file in *; do
    new_name=$(printf '%s' "$file" \
        | tr '[:upper:]' '[:lower:]' \
        | sed 's/[[:space:]-]/_/g; s/__*/_/g')

    if [ "$file" != "$new_name" ]; then
        mv -v "$file" "$new_name"
    fi
done

green_message "Success:" "Converted '$target_dir' to snake_case."
