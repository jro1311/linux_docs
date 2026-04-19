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

# Installs missing packages
packages=("git")
for package in "${packages[@]}"; do
    inverse_check "$package" \
        install_packages "$package"
done

read -er -p "Enter local directory (default: ${HOME}/Documents/linux_docs): " local_dir
local_dir=${local_dir:-"$HOME/Documents/linux_docs"}
backup_dir="${local_dir}_old"

if [ ! -d "$local_dir" ]; then
    red_message "Error:" "'$local_dir' does not exist."
    exit 1
fi

green_message "Local Directory:" "$local_dir"

read -er -p "Enter GitHub URL (default: https://github.com/jro1311/linux_docs.git): " repo_url
repo_url=${repo_url:-"https://github.com/jro1311/linux_docs.git"}

if ! curl -sIf "$repo_url" >/dev/null 2>&1; then
    red_message "Error:" "Failed to reach '$repo_url'."
    exit 1
fi

green_message "GitHub URL:" "$repo_url"
confirm_proceed

# Moves existing local_dir to a numbered backup directory
if [ -d "$backup_dir" ]; then
    count=1
    new_dir="$backup_dir"

    while [ -d "$new_dir" ]; do
        new_dir="$backup_dir$count"
        count=$((count + 1))
    done
    mv -v "$local_dir" "$new_dir"

elif [ -d "$local_dir" ]; then
    mv -v "$local_dir" "$backup_dir"

fi

git clone "$repo_url" "$local_dir"

# Optionally remove all numbered backup directories
if ask_for_confirmation "Remove ${local_dir}_old directory(s)?"; then
    shopt -s nullglob
    rm -rf "${local_dir}_old"*
    shopt -u nullglob
fi

run_script "$HOME/Documents/linux_docs/scripts/chmod_scripts.sh"

green_message "Success:" "Cloned GitHub repository."
