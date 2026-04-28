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

confirm_proceed

mapfile -t user_pkgs < <(
    snap list | awk '!/^Name/ {print $1}' |
    grep -Ev '^(bare|core|core18|core20|core22|core24|core26|snapd)$'
)

# Remove non-base snaps first to avoid dependency failures
for user_pkg in "${user_pkgs[@]}"; do
    sudo snap remove --purge "$user_pkg"
done

base_pkgs=(
    bare
    core
    core18
    core20
    core22
    core24
    core26
    snapd
)

# Remove base snaps in this order to avoid dependency failures
for base_pkg in "${base_pkgs[@]}"; do
    if snap list "$base_pkg" >/dev/null 2>&1; then
        sudo snap remove --purge "$base_pkg"
    fi
done

pkg="snapd"

case "$primary_pm" in
    apt|dnf|eopkg|xbps|zypper|rpm-ostree) remove_pm_pkg_bypass "$pkg" ;;
    pacman) remove_aur_pkg_bypass "$pkg" ;;
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
        sudo zypper rr snappy || true
        ;;
esac

sudo rm -rf /var/cache/snapd || true
sudo rm -rf /snap || true
rm -rf "$HOME/snap" || true

sudo systemctl mask \
    snapd.socket \
    snapd.service \
    snapd.seeded.service

green_message "Success:" "Snap removed from system."
