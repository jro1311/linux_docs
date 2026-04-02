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

fi

# Define the source directory
source_dir="$HOME/Documents/linux_docs"

# Validates directory
if [ ! -d "$source_dir" ]; then
    red_message "Error:" "'$source_dir' does not exist."
    exit 1
fi

if [ ! -d "$source_dir/.git" ]; then
    red_message "Error:" "'$source_dir/.git' does not exist."
    exit 1
fi

cd "$source_dir"

# Creates a backup just in case
git branch backup-"$(date +%s)"

# Retrieves updates from remote repository and displays changes
git fetch origin
git diff HEAD origin/main

# Prompts the user to accept changes
if ask_for_confirmation "Accept changes?"; then

    # Mirrors remote repository
    git reset --hard origin/main

else
    echo "No changes were made."
    exit 1
fi

# Recursively finds all .sh files and sets them as executable
find "$HOME/Documents/linux_docs/scripts" -type f \
    -name "*.sh" \
    -exec chmod +x {} +

green_message "Git sync complete."
