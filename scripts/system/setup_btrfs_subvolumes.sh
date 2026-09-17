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

if [ -f /run/ostree-booted ]; then
    red_message "Error:" "Incompatible immutable OSTree system."
    exit 1
fi

detect_system

if [ "$root_fs" != "btrfs" ] \
    && [ "$home_fs" != "btrfs" ] \
    && [ "$var_fs" != "btrfs" ]; then

    red_message "Error:" "No btrfs filesystems detected on '/', '/home', or '/var'."
    exit 1
fi

confirm_proceed

trap unmount_on_error EXIT
mount_root_dev

backup_path="/etc/fstab.backup.$(date +%Y%m%d-%H%M%S)"
sudo cp /etc/fstab "$backup_path"

created_subvols=()
renamed_subvols=()
migrated_dirs=()

print_summary() {
    local subvol dir

    if [ "${#created_subvols[@]}" -gt 0 ]; then
        green_message "Created Subvolumes:"
        for subvol in "${created_subvols[@]}"; do
            printf '  %s\n' "$subvol"
        done
    fi

    if [ "${#renamed_subvols[@]}" -gt 0 ]; then
        printf '\n'
        green_message "Renamed Subvolumes:"
        for subvol in "${renamed_subvols[@]}"; do
            printf '  %s\n' "$subvol"
        done
    fi

    if [ "${#migrated_dirs[@]}" -gt 0 ]; then
        printf '\n'
        green_message "Migrated Directories:"
        for dir in "${migrated_dirs[@]}"; do
            printf '  %s\n' "$dir"
        done
    fi
}

if [ "$root_fs" = "btrfs" ]; then
    if [ -d /mnt/@rootfs ]; then
        _rename_subvol "@rootfs" "@" "/"
    elif [ -d /mnt/root ]; then
        _rename_subvol "root" "@" "/"
    else
        _create_subvol "@"
    fi
fi

if [ "$home_fs" = "btrfs" ]; then
    if sudo btrfs subvolume show /mnt/home >/dev/null 2>&1; then
        _rename_subvol "home" "@home" "/home"
    else
        _create_subvol "@home"
        add_subvol_mount "@home" "/home"
        _migrate_dir_data "@home" "/home"
    fi
fi

if [ "$var_fs" = "btrfs" ]; then
    _create_subvol      "@flatpak"
    add_subvol_mount    "@flatpak" "/var/lib/flatpak"
    _migrate_dir_data   "@flatpak" "/var/lib/flatpak" "flatpak repair || :"

    _create_subvol      "@libvirt-images"
    add_subvol_mount    "@libvirt-images" "/var/lib/libvirt/images"
    _migrate_dir_data   "@libvirt-images" "/var/lib/libvirt/images"

    _create_subvol          "@cache"
    add_subvol_mount        "@cache" "/var/cache"
    sudo find /mnt/@/var/cache -mindepth 1 -delete
fi

apply_btrfs_cow_policies

restore_needed_paths=()
var_paths=(
    /var/lib/flatpak
    /var/lib/libvirt
    /var/lib/libvirt/images
    /var/cache
)

# Restore SELinux labels only when necessary
for path in "${var_paths[@]}"; do
    if ! matchpathcon "$path" >/dev/null 2>&1; then
        restore_needed_paths+=("$path")
    fi
done

if [ "${#restore_needed_paths[@]}" -gt 0 ]; then
    restorecon_paths "${restore_needed_paths[@]}"
fi

sudo umount /mnt

case "$init_system" in
    systemd) sudo systemctl daemon-reload ;;
esac

sudo mount -a

if ! sudo findmnt --verify --verbose; then
    confirm_proceed
fi

update_bootloader
print_summary

