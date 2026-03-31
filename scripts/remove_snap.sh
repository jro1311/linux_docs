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

# Checks for init system
if ps -p 1 -o comm= | grep -Fq "systemd"; then
    green_message "Init System: systemd"
else
    red_message "Unsupported init system."
    exit 1
fi

# Define package managers
primary_package_manager="unknown"
secondary_package_manager="unknown"

primary_package_managers=(apt dnf eopkg pacman xbps-install zypper rpm-ostree)
secondary_package_managers=(nala paru yay)

for cmd in "${primary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        primary_package_manager="$cmd"
        break
    fi
done

for cmd in "${secondary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        secondary_package_manager="$cmd"
        break
    fi
done

# Normalize xbps-install to xbps
if [ "$primary_package_manager" = "xbps-install" ]; then
    primary_package_manager="xbps"
fi

if [ "$primary_package_manager" != "unknown" ]; then
    green_message "Primary Package Manager:" "$primary_package_manager"
fi

if [ "$secondary_package_manager" != "unknown" ]; then
    green_message "Secondary Package Manager:" "$secondary_package_manager"
fi

# Checks for Snap then removes all related packages
if command -v snap >/dev/null 2>&1; then
    sudo systemctl disable --now snapd

    # Removes user-installed package(s)
    for user_package in $(snap list | awk '!/^Name/ {print $1}' | grep -Ev '^(bare|core|core18|core20|core22|core24|snapd|gtk-common-themes)$'); do
        sudo snap disable "$user_package" && sudo snap remove --purge "$user_package"
    done

    # Removes theme/base package(s)
    for base_package in gtk-common-themes bare core core18 core20 core22 core24 snapd; do
        if snap list | grep -q "^$base_package "; then
            sudo snap remove --purge "$base_package"
        fi
    done

    packages=("snapd")
    remove_packages "${packages[@]}"

    case "$primary_package_manager" in
        "apt")
            # Locks package(s) from being reinstalled automatically
            if ! apt-mark showhold | grep -q "^snapd$"; then
                sudo apt-mark hold snapd
            fi
            ;;
        "zypper")
            # Removes repo(s)
            sudo zypper rr snappy
            ;;
    esac

    if [ -d /var/cache/snapd ]; then
        sudo rm -rfv /var/cache/snapd
    fi

    if [ -d /snap ]; then
        sudo rm -rfv /snap
    fi

    if [ -d "$HOME/snap" ]; then
        rm -rfv "$HOME/snap"
    fi

    green_message "Snap has been removed from the system."

else
    yellow_message "Snap not detected."
    exit 1
fi
