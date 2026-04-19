#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154,SC2016

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Sources all .sh files in bashrc.d
shopt -s globstar nullglob

for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f "$rc" ]] && source "$rc"
done
unset rc

shopt -u globstar nullglob

# Installs missing packages
packages=("perl")
for package in "${packages[@]}"; do
    inverse_check "$package" \
        install_packages "$package"
done

read -er -p "Enter the path of the target directory (default: $HOME/Documents): " target_dir

target_dir=${target_dir:-$HOME/Documents}

# Normalizes user input so ~ and $HOME expand to absolute paths
target_dir="${target_dir/#~/$HOME}"
target_dir="${target_dir/#\$HOME/$HOME}"

if [ ! -d "$target_dir" ]; then
    red_message "Error:" "'$target_dir' does not exist."
    exit 1
fi

green_message "Target:" "$target_dir"

read -r -p "Enter the current text: " current_text

if [ -z "$current_text" ]; then
    red_message "Error:" "No text entered."
    exit 1
fi

read -r -p "Enter the new text: " new_text

matches="$(sudo_run_passthrough find "$target_dir" -type f -exec grep -Fl -- "$current_text" {} \; 2>/dev/null)"

if [ -z "$matches" ]; then
    yellow_message "No matches found:" "'$current_text' not found in any files."
    exit 0
fi

yellow_message "Review:" "The following files will be modified."
printf "%s\n" "$matches" | sed "s/^/  /"

confirm_proceed

# Applies text replacement to each matched file
printf "%s\n" "$matches" | while IFS= read -r file; do
    sudo_run_passthrough env \
        current_text="$current_text" \
        new_text="$new_text" \
        perl -pi -e 's/\Q$ENV{current_text}\E/$ENV{new_text}/g' "$file"
done
  
green_message "Success:" "Replaced text in '$target_dir."
