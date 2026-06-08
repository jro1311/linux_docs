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

print_summary() {
    local subvol

    if [ "${#created_subvols[@]}" -gt 0 ]; then
        green_message "Created Subvolumes:"
        for subvol in "${created_subvols[@]}"; do
            printf '  %s\n' "$subvol"
        done
    fi
}

create_btrfs_swapfile() {
    if ! mountpoint -q /swap; then
        mount_root_dev

        _create_subvol "swap"
        add_subvol_mount "swap" "/swap"

        sudo umount /mnt
    fi

    if ! grep -Fq "/swap/swapfile" /etc/fstab; then
        echo '/swap/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab >/dev/null

        case "$init_system" in
            systemd) sudo systemctl daemon-reload ;;
        esac
    fi

    sudo mkdir -p /swap
    sudo mount /swap || :

    sudo btrfs filesystem mkswapfile --size "${swap_size}g" --uuid clear /swap/swapfile
    sudo swapon /swap/swapfile
    sudo swapon --show
}

create_normal_swapfile() {
    sudo fallocate -l "${swap_size}G" /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    sudo swapon --show

    if ! grep -Fq "/swapfile" /etc/fstab; then
        echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null

        case "$init_system" in
            systemd) sudo systemctl daemon-reload ;;
        esac
    fi
}

if [ "$root_fs" = "btrfs" ]; then
    created_subvols=()
    trap unmount_on_error EXIT

    create_btrfs_swapfile
    print_summary
else
    create_normal_swapfile
fi

swapfile_exists=1
remove_zram

green_message "Success:" "Swapfile created."
