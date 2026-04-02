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

if ! command -v git >/dev/null 2>&1; then

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

    packages=("git")
    install_packages "${packages[@]}"

    if [ "$primary_package_manager" = "rpm-ostree" ]; then
        echo "Reboot to apply changes and run the script again."
        exit 0
    fi

fi

# Define the local and backup directories
read -er -p "Enter local directory (default: ${HOME}/Documents/linux_docs): " local_dir
local_dir=${local_dir:-"$HOME/Documents/linux_docs"}
backup_dir="${local_dir}_old"

# Validates directory
if [ ! -d "$local_dir" ]; then
    red_message "Error:" "'$local_dir' does not exist."
    exit 1
fi

green_message "Local Directory:" "$local_dir"

# Define GitHub URL
read -er -p "Enter GitHub URL (default: https://github.com/jro1311/linux_docs.git): " repo_url
repo_url=${repo_url:-"https://github.com/jro1311/linux_docs.git"}

# Validates URL
if ! curl -sIf "$repo_url" >/dev/null 2>&1; then
    red_message "Error:" "Failed to reach '$repo_url'."
    exit 1
fi

green_message "GitHub URL:" "$repo_url"
read -r -p "Press enter to proceed, or ctrl+c to cancel: "

# Checks for directory and renames using numbered naming logic
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

# Clones git repository to local directory
git clone "$repo_url" "$local_dir"

# Enable nullglob so that the glob expands to nothing if no match
shopt -s nullglob

# Prompts user to remove old directories
if ask_for_confirmation "Remove ${local_dir}_old directory(s)?"; then
    rm -rf "${local_dir}_old"*
fi

# Recursively finds all .sh files in linux_docs and sets them as executable
if [ -d "$HOME/Documents/linux_docs/scripts" ]; then
    find "$HOME/Documents/linux_docs/scripts" -type f \
        -name "*.sh" \
        -exec chmod +x {} +
fi

green_message "Git clone complete."
