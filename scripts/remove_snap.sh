#!/usr/bin/env bash
# shellcheck disable=SC2154

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

if [ "$init_system" != "systemd" ]; then
    unsupported_init_system
    exit 1
fi

if [ "$snap_installed" -eq 0 ]; then
    yellow_message "Snap is not installed."
    exit 1
fi

print_field "Primary Package Manager" "$primary_pm"
print_field "Secondary Package Manager" "$secondary_pm"
print_field "Init System" "$init_system"

read -r -p "Press enter to proceed, or ctrl+c to cancel: "
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
case "$primary_pm" in
    "apt"|"dnf"|"eopkg"|"xbps"|"zypper"|"rpm-ostree")
        remove_packages "${packages[@]}"
        ;;
    "pacman")
        case "$secondary_pm" in
            "paru"|"yay")
                "$secondary_pm" -Rs --noconfirm "${packages[@]}"
                ;;
            *)
                sudo pacman -Rs --noconfirm "${packages[@]}"
                ;;
        esac
        ;;
    *)
        unsupported_package_manager
        exit 1
esac

case "$primary_pm" in
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

green_message "Success:" "Snap removed from system."
