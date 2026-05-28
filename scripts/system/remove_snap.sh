#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

ld_bash_dir="$HOME/Documents/linux_docs/configs/system/bash/bash.d"

shopt -s nullglob globstar
for file in "$ld_bash_dir"/**/*.sh; do
    [ -e "$file" ] || continue
    . "$file"
done
shopt -u nullglob globstar

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

sudo rm -rf /var/cache/snapd
sudo rm -rf /snap
rm -rf "$HOME/snap"

case "$primary_pm" in
    zypper) sudo zypper rr snappy || : ;;
esac

if [ "$os" = "ubuntu" ]; then
    lock_pm "$pkg"
fi

sudo systemctl mask \
    snapd.socket \
    snapd.service \
    snapd.seeded.service

green_message "Success:" "Snap removed from system."
