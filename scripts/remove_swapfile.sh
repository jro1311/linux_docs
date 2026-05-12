#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

bashd_dir="$HOME/Documents/linux_docs/configs/system/bash/bashrc.d"

for file in "$bashd_dir"/*.sh; do
    [ -e "$file" ] || continue
    . "$file"
done

for dir in helpers configure_packages install_packages; do
    for file in "$bashd_dir/$dir"/*.sh; do
        [ -e "$file" ] || continue
        . "$file"
    done
done

detect_system

if [ "$swapfile_exists" -eq 0 ]; then
    yellow_message "Not detected:" "Swapfile"
    exit 0
fi

confirm_proceed

sudo swapoff "$swapfile_path"
sudo rm "$swapfile_path"
sudo sed -i "\|$swapfile_path|d" /etc/fstab

if sudo btrfs subvolume show /swap >/dev/null 2>&1; then
    sudo btrfs subvolume delete /swap
fi

swapfile_exists=0

if [ "$swapfile_exists" -eq 0 ] && [ "$swap_partition_exists" -eq 0 ]; then
    _disable_zswap
    sudo rm -f /etc/sysctl.d/99-zswap.conf
fi

green_message "Success:" "Swapfile removed."
