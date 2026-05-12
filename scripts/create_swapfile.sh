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

if [ "$swapfile_exists" -eq 1 ]; then
    yellow_message "Already detected:" "Swapfile"
    exit 0
fi

if [ "$swap_partition_exists" -eq 1 ]; then
    red_message "Error:" "Swap partition exists."
    exit 1
fi

swap_size=$(input_positive_integer "swapfile size [1-32 GiB]")

if [ "$swap_size" -gt 32 ]; then
    red_message "Error:" "Maximum allowed swapfile size is 32 GiB."
    exit 1
fi

green_message "Swapfile size:"  "$swap_size GiB"
confirm_proceed

if [ "$root_fs" = "btrfs" ]; then
    if ! sudo btrfs subvolume show /swap >/dev/null 2>&1; then
        sudo btrfs subvolume create /swap
    fi

    sudo btrfs filesystem mkswapfile --size "${swap_size}g" --uuid clear /swap/swapfile
    sudo swapon /swap/swapfile
    echo '/swap/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab >/dev/null 2>&1
    sudo swapon --show
else
    sudo fallocate -l "${swap_size}G" /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null 2>&1
    sudo swapon --show
fi

swapfile_exists=1

remove_zram

green_message "Success:" "Swapfile created."
