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

print_field "Root File System" "$root_fs"

if [ "$battery_detected" -eq 1 ]; then
    print_field "Detected" "Battery"
fi

if [ "$swapfile_exists" -eq 0 ]; then
    yellow_message "Not detected:" "Swapfile"
    exit 1
fi

confirm_proceed

sudo swapoff "$swap_path"
sudo rm -v "$swap_path"
sudo sed -i "\|$fstab_pattern|d" /etc/fstab

if sudo btrfs subvolume show /swap >/dev/null 2>&1; then
    sudo btrfs subvolume delete /swap
fi

if grep -Fq "Y" /sys/module/zswap/parameters/enabled; then
    if ask_for_confirmation "Disable zswap and install zram?"; then
        disable_zswap
        install_zram
    fi
fi

swapfile_exists=0

green_message "Success:" "Swapfile removed."
