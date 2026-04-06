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

# Checks that packages are installed
packages=("perl")
for package in "${packages[@]}"; do
    inverse_check "$package" \
        install_packages "$package"
done

# Prompts the user for input
read -er -p "Enter the path of the target directory (default: $HOME/Documents): " target_dir

# Define target directory
target_dir=${target_dir:-$HOME/Documents}

# Expands ~ or $HOME to the full path
target_dir="${target_dir/#~/$HOME}"
target_dir="${target_dir/#\$HOME/$HOME}"

# Validates directory
if [ ! -d "$target_dir" ]; then
    red_message "Error:" "'$target_dir' does not exist."
    exit 1
fi

green_message "Target:" "$target_dir"

read -r -p "Enter the current text: " current_text
read -r -p "Enter the new text: " new_text

if ask_for_confirmation "Run a dry run first?"; then
    sudo_run_passthrough find "$target_dir" -type f -exec grep -Fli -- "$current_text" {} \; 2>/dev/null
fi

read -r -p "Press enter to proceed, or ctrl+c to cancel: "

# shellcheck disable=SC2016

# Replaces text in all files under target_directory
sudo_run_passthrough find "$target_dir" -type f -exec env current_text="$current_text" new_text="$new_text" \
  perl -pi -e 's/\Q$ENV{current_text}\E/$ENV{new_text}/g' {} + 2>/dev/null
  
green_message "Success:" "Replaced text in '$target_dir."
