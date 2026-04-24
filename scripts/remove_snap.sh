#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# shellcheck disable=SC2044
# Sources all .sh files in bashrc.d
for rc in $(find "$HOME/Documents/linux_docs/configs/system/bash/bashrc.d" -type f -name '*.sh' 2>/dev/null); do
    . "$rc"
done

detect_system

if [ "$snap_installed" -eq 0 ]; then
    red_message "Error:" "Snap is not installed."
    exit 1
fi

if [ "$init_system" != "systemd" ]; then
    unsupported_init_system
    exit 1
fi

print_primary_pm
print_init_system
confirm_proceed

sudo systemctl disable --now snapd

# Maps lines of input into an array
mapfile -t user_packages < <(
    snap list | awk '!/^Name/ {print $1}' |
    grep -Ev '^(bare|core|core18|core20|core22|core24|snapd)$'
)

# Removes user-installed package(s) first
for user_package in "${user_packages[@]}"; do
    sudo snap remove --purge "$user_package"
done

base_packages=(
    bare
    core
    core18
    core20
    core22
    core24
    core26
    snapd
)

# Removes base package(s) second
for base_package in "${base_packages[@]}"; do
    if snap list "$base_package" >/dev/null 2>&1; then
        sudo snap remove --purge "$base_package"
    fi
done

packages=("snapd")
case "$primary_pm" in
    apt|dnf|eopkg|xbps|zypper|rpm-ostree) remove_pm_pkg_bypass "${packages[@]}" ;;
    pacman) remove_aur_pkg_bypass "${packages[@]}" ;;
    *)
        unsupported_package_manager
        exit 1
esac

case "$primary_pm" in
    apt)
        # Locks package(s) from being reinstalled automatically
        if ! apt-mark showhold "snapd" 2>/dev/null | grep -Fq "snapd"; then
            sudo apt-mark hold snapd
        fi
        ;;
    zypper)
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
