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

if [ "$swapfile_exists" -eq 1 ]; then
    yellow_message "Already detected:" "Swapfile"
    exit 1
fi

read -rp "Enter size for swapfile [GiB]: " number

# Checks that value is a positive number
if [[ ! "$number" =~ ^[0-9]+$ ]]; then
    red_message "Error:" "Value is not valid."
    yellow_message "Note:" "Enter a positive number."
    exit 1
fi

# Checks that value is within limits
if [ "$number" -gt 32 ]; then
    red_message "Error:" "Value is too large."
    yellow_message "Note:" "Maximum allowed swapfile size is 32 GiB."
    exit 1
fi

green_message "Swapfile size set to $number GiB."

if [ "$root_fs" = "btrfs" ]; then
    if ! sudo btrfs subvolume show /swap >/dev/null 2>&1; then
        sudo btrfs subvolume create /swap
    fi

    sudo btrfs filesystem mkswapfile --size "${number}g" --uuid clear /swap/swapfile
    sudo swapon /swap/swapfile
    echo '/swap/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab >/dev/null 2>&1
    sudo swapon --show
else
    sudo fallocate -l "${number}G" /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null 2>&1
    sudo swapon --show
fi

if grep -Fq "N" /sys/module/zswap/parameters/enabled \
    && confirm "Enable zswap? [y/N]"; then
    remove_zram
    enable_zswap
else
    sudo mkdir -p /etc/sysctl.d
    sudo cp "$HOME/Documents/linux_docs/configs/system/99-swap.conf" /etc/sysctl.d/
    sudo sysctl -p /etc/sysctl.d/99-swap.conf
fi

swapfile_exists=1

green_message "Success:" "Swapfile created."
