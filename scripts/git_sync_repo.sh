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
packages=("git")
for package in "${packages[@]}"; do
    inverse_check "$package" \
        install_packages "$package"
done

# Define the local directory
read -er -p "Enter local directory (default: ${HOME}/Documents/linux_docs): " local_dir
local_dir=${local_dir:-"$HOME/Documents/linux_docs"}

# Validates directory
if [ ! -d "$local_dir" ]; then
    red_message "Error:" "'$local_dir' does not exist."
    exit 1
fi

if [ ! -d "$local_dir/.git" ]; then
    red_message "Error:" "'$local_dir/.git' does not exist."
    exit 1
fi

green_message "Local Directory:" "$local_dir"
cd "$local_dir"

# Creates a backup of current local branch
git branch backup-"$(date +%s)"

# Fetches updates from remote repository
git fetch origin

# Checks for differences
if git diff --quiet HEAD origin/main; then
    echo "No changes detected."
    exit 0
fi

# Shows the differences
git diff HEAD origin/main

# Prompts the user to accept changes
if ask_for_confirmation "Accept changes?"; then
    git reset --hard origin/main
else
    echo "No changes were made."
    exit 1
fi

# Recursively finds all .sh files linux_docs and sets them as executable
if [ -d "$HOME/Documents/linux_docs/scripts" ]; then
    find "$HOME/Documents/linux_docs/scripts" -type f \
        -name "*.sh" \
        -exec chmod +x {} +
fi

green_message "Git sync complete."
