#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

ld_bash_dir="$HOME/Documents/linux_docs/configs/system/bash/bash.d"

for file in "$ld_bash_dir"/*.sh; do
    [ -e "$file" ] || continue
    . "$file"
done

for dir in helpers configure_packages install_packages; do
    for file in "$ld_bash_dir/$dir"/*.sh; do
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

swapfile_config=$(select_swapfile_config)

if [ -z "$swapfile_config" ]; then
    exit 0
fi

case "$swapfile_config" in
    auto-detect)
        if [ "$ram_gib" -le 2 ]; then
            swap_size=2
        elif [ "$ram_gib" -le 8 ]; then
            swap_size=4
        elif [ "$ram_gib" -le 12 ]; then
            swap_size=6
        else
            swap_size=8
        fi
        ;;
    custom)
        swap_size=$(input_positive_integer "swapfile size [1-8 GiB]")

        if [ "$swap_size" -gt 8 ]; then
            red_message "Error:" "Maximum allowed swapfile size is 8 GiB."
            exit 1
        fi
        ;;
esac

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
