#!/usr/bin/env bash
# shellcheck source=/dev/null

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
packages=("git")
for package in "${packages[@]}"; do
    inverse_check "$package" \
        install_packages "$package"
done

read -er -p "Enter local directory (default: ${HOME}/Documents/linux_docs): " local_dir
local_dir=${local_dir:-"$HOME/Documents/linux_docs"}

# Normalizes user input so ~ and $HOME expand to absolute paths
local_dir="${local_dir/#~/$HOME}"
local_dir="${local_dir/#\$HOME/$HOME}"

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

read -er -p "Enter remote (default: origin): " remote
remote=${remote:-origin}

read -er -p "Enter branch (default: main): " branch
branch=${branch:-main}

if ! git show-ref --verify --quiet "refs/remotes/$remote/$branch"; then
    red_message "Error:" "'$remote/$branch' does not exist."
    exit 1
fi

green_message "Remote Branch:" "$remote/$branch"

# Creates a backup of current local branch
git branch backup-"$(date +%s)"

# Fetches updates from remote repository
git fetch "$remote"

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

run_script "$HOME/Documents/linux_docs/scripts/chmod_scripts.sh"

green_message "Success:" "Synced local directory with GitHub repository."
