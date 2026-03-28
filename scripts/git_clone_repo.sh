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
shopt -s nullglob

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
        green_message "Primary Package Manager: $primary_package_manager"
    fi

    packages=("git")
    install_packages "${packages[@]}"

fi

# Define the source/base directories and the github repository
source_dir="$HOME/Documents/linux_docs"
base_dir="$HOME/Documents/linux_docs_old"
repo_url="https://github.com/jro1311/linux_docs.git"

# Checks for directory and renames using numbered naming logic
if [ -d "$base_dir" ]; then
    count=1
    new_dir="$base_dir"

    while [ -d "$new_dir" ]; do
        new_dir="$base_dir$count"
        count=$((count + 1))
    done

    mv -v "$source_dir" "$new_dir"

elif [ -d "$source_dir" ]; then
    mv -v "$source_dir" "$base_dir"

fi

git clone "$repo_url" "$source_dir"

# Enable nullglob so that the glob expands to nothing if no match
shopt -s nullglob

if ask_for_confirmation "Remove linux_docs_old directory(s)?"; then
    rm -rf "$HOME/Documents/linux_docs_old"*
fi

# Recursively finds all .sh files and sets them as executable
find "$HOME/Documents/linux_docs/scripts" -type f \
    -name "*.sh" \
    -exec chmod +x {} +

green_message "Git clone complete."
