#!/usr/bin/env bash

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

# Prompts the user for input
read -er -p "Enter the path of the target directory (default: $HOME/Documents/): " target_dir

# Uses default if no input is given
target_dir=${target_dir:-$HOME/Documents/}

# Expands ~ or $HOME to the full path
target_dir="${target_dir/#~/$HOME}"
target_dir="${target_dir/#\$HOME/$HOME}"

# Validates directory
if [ ! -d "$target_dir" ]; then
    red_message "Error:" "'$target_dir' does not exist."
    exit 1
fi

green_message "Target:" "$target_dir"

format="unknown"
format_cmd="unknown"

if ask_for_confirmation "Convert to spaces?"; then
    format="spaces"
    format_cmd="expand"
elif ask_for_confirmation "Convert to tabs?"; then
    format="tabs"
    format_cmd="unexpand"
fi

if [ "$format" != "unknown" ]; then
     read -r -p "Press enter to proceed, or ctrl+c to cancel: "

    # # Recursively finds all .md, .txt, and .sh files and converts them
    for ext in md txt sh; do
        find "$target_dir" -type f \
        -name "*.$ext" \
        -exec sh -c '
            format_cmd="$1"
            shift

            for file do
                echo "Converting $file..."
                "$format_cmd" -t 4 -- "$file" > "$file.tmp" && mv "$file.tmp" "$file"
            done
        ' sh "$format_cmd" {} +
    done

    green_message "Success:" "Converted '$target_dir' to $format."
fi
