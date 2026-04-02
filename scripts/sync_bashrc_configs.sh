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

if ! command -v rsync >/dev/null 2>&1; then

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

    packages=("rsync")
    install_packages "${packages[@]}"

    if [ "$primary_package_manager" = "rpm-ostree" ]; then
        echo "Reboot to apply changes and run the script again."
        exit 0
    fi

fi

mkdir -pv "$HOME/.bashrc.d"

# Define source and destination directory
source_dir="$HOME/Documents/linux_docs/configs/system/bash/bashrc.d/"
destination_dir="$HOME/.bashrc.d/"

# Validates directory
if [ ! -d "$source_dir" ]; then
    red_message "Error:" "'$source_dir' does not exist."
    exit 1
fi

# shellcheck disable=SC2016

# Enables recursive sourcing of all .sh files in "$HOME/.bashrc.d"
if ! grep -Fq '# Sources all .sh files in $HOME/.bashrc.d' "$HOME/.bashrc"; then
    cat "$HOME/Documents/linux_docs/configs/system/bash/bashrc" >> "$HOME/.bashrc"
    green_message "Enabled recursive sourcing in '$HOME/.bashrc.d'."
fi

# Syncs the source with the destination and checks if it was successful
if rsync -auhvP --delete "$source_dir" "$destination_dir"; then
    green_message "Success:" "'$source_dir' synced with '$destination_dir'"
else
    red_message "Error:" "'$source_dir' failed to sync with '$destination_dir'"
    exit 1
fi
