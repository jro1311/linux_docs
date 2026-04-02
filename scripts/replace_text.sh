#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Sources all .sh files in $HOME/Documents/linux_docs/configs/system/bash/bashrc.d
shopt -s globstar nullglob

# shellcheck source=/dev/null
for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f $rc ]] && source "$rc"
done
unset rc

shopt -u globstar nullglob

if ! command -v perl >/dev/null 2>&1; then

    # Define primary package manager
    primary_package_manager="unknown"
    primary_package_managers=(apt dnf eopkg pacman xbps-install zypper rpm-ostree)

    for cmd in "${primary_package_managers[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            primary_package_manager="$cmd"
            break
        fi
    done

    # Normalizes xbps-install to xbps
    if [ "$primary_package_manager" = "xbps-install" ]; then
        primary_package_manager="xbps"
    fi

    if [ "$primary_package_manager" != "unknown" ]; then
        green_message "Primary Package Manager:" "$primary_package_manager"
    fi

    packages=("perl")
    install_packages "${packages[@]}"

fi

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
  
green_message "Replacement complete."
