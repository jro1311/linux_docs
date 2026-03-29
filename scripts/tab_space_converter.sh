#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Sources all .sh files in $HOME/Documents/linux_docs/configs/system/bash/bashrc.d
shopt -s globstar nullglob

# shellcheck source=/dev/null
for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f $rc ]] && source "$rc"
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
    red_message "$target_dir does not exist."
    exit 1
fi

green_message "Target: $target_dir"

if ask_for_confirmation "Convert to spaces?"; then
    green_message "Converting tabs to spaces..."
    read -r -p "Press enter to proceed, or ctrl+c to cancel: "
    
    # Recursively finds all .md, .txt, and .sh files and converts them to spaces
    for ext in md txt sh; do
        find "$target_dir" -type f \
        -name "*.$ext" \
        -exec sh -c '
            for file do
                echo "Converting $file..."
                expand -t 4 -- "$file" > "$file.tmp" && mv "$file.tmp" "$file"
            done
        ' sh {} +
    done

elif ask_for_confirmation "Convert to tabs?"; then
    green_message "Converting spaces to tabs..."
    read -r -p "Press enter to proceed, or ctrl+c to cancel: "

    # Recursively finds all .md, .txt, and .sh files and converts them to tabs
    for ext in md txt sh; do
        find "$target_dir" -type f \
        -name "*.$ext" \
        -exec sh -c '
            for file do
                echo "Converting $file..."
                unexpand -t 4 -- "$file" > "$file.tmp" && mv "$file.tmp" "$file"
            done
        ' sh {} +
    done
fi

green_message "Conversion complete."
