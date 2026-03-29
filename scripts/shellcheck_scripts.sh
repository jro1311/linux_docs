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

if ! command -v shellcheck >/dev/null 2>&1; then

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

    packages=("shellcheck")
    install_packages "${packages[@]}"

fi

error_found=0

# Recursively checks all .sh files for errors
while IFS= read -r -d '' script; do
    if ! shellcheck -x "$script"; then
        error_found=1
    fi
done < <(find "$HOME/Documents/linux_docs/scripts" -type f -name '*.sh' -print0)

if [ "$error_found" -eq 0 ]; then
    green_message "No errors were found in any script."
fi

exit "$error_found"
