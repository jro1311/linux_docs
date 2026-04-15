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

# Expand ~ or $HOME to the full path
local_dir="${local_dir/#~/$HOME}"
local_dir="${local_dir/#\$HOME/$HOME}"

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

# Define branch
read -er -p "Enter remote (default: origin): " remote
remote=${remote:-origin}

read -er -p "Enter branch (default: main): " branch
branch=${branch:-main}

# Validates branch
if ! git show-ref --verify --quiet "refs/remotes/$remote/$branch"; then
    red_message "Error:" "'$remote/$branch' does not exist."
    exit 1
fi

green_message "Remote Branch:" "$remote/$branch"

# Creates a backup of current local branch
git branch backup-"$(date +%s)"

# Fetches updates from remote repository
git fetch origin

# Checks for differences between local and remote branch
if git diff --quiet HEAD "$remote/$branch"; then
    green_message "Already up to date:" "Nothing to do."
    exit 0
fi

# Shows the differences
git diff HEAD "$remote/$branch" || true

# Prompts the user to accept changes
if ask_for_confirmation "Accept changes?"; then
    git reset --hard "$remote/$branch"
else
    echo "No changes were made."
    exit 0
fi

# Recursively finds all .sh files linux_docs and sets them as executable
if [ -d "$HOME/Documents/linux_docs/scripts" ]; then
    find "$HOME/Documents/linux_docs/scripts" -type f \
        -name "*.sh" \
        -exec chmod +x {} +
fi

green_message "Success:" "Synced local directory with GitHub repository."
