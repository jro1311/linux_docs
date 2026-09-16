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

setup_root_subvol() {
    # Case 1: Debian default (@rootfs)
    if [ -d /mnt/@rootfs ]; then
        if [ ! -d /mnt/@ ]; then
            sudo mv /mnt/@rootfs /mnt/@
            sudo sed -i '/[[:space:]]\/[[:space:]]/ s/\<subvol=@rootfs\>/subvol=@/' /etc/fstab
            renamed_subvols+=("@rootfs -> @")
        fi

        return 0
    fi

    # Case 2: Fedora default (root)
    if [ -d /mnt/root ]; then
        if [ ! -d /mnt/@ ]; then
            sudo mv /mnt/root /mnt/@
            sudo sed -i '/[[:space:]]\/[[:space:]]/ s/\<subvol=root\>/subvol=@/' /etc/fstab
            renamed_subvols+=("root -> @")
        fi

        return 0
    fi

    # Case 3: Other
    if [ ! -d /mnt/@ ]; then
        sudo btrfs subvolume create /mnt/@
        created_subvols+=("@")
    fi
}

setup_home_subvol() {
    # Case 1: /mnt/home is a subvolume
    if sudo btrfs subvolume show /mnt/home >/dev/null 2>&1; then
        if [ ! -d /mnt/@home ]; then
            sudo mv /mnt/home /mnt/@home
            sudo sed -i '/[[:space:]]\/home[[:space:]]/ s/\<subvol=home\>/subvol=@home/' /etc/fstab
            renamed_subvols+=("home -> @home")
        fi

        return 0
    fi

    # Case 2: /mnt/home is a directory
    if [ -d /mnt/home ]; then
        if [ ! -d /mnt/@home ] || [ ! -f /mnt/@home/.migration-complete ]; then
            sudo btrfs subvolume create /mnt/@home 2>/dev/null || :

            if sudo rsync -aHAXP /mnt/home/ /mnt/@home/; then
                sudo find /mnt/home -mindepth 1 -delete
                sudo touch /mnt/@home/.migration-complete
                created_subvols+=("@home")
                migrated_dirs+=("/home -> @home")
            fi
        fi

        return 0
    fi

    # Case 3: Other
    if [ ! -d /mnt/@home ]; then
        sudo btrfs subvolume create /mnt/@home
        created_subvols+=("@home")
    fi
}

[ "$root_fs" = "btrfs" ] && setup_root_subvol
[ "$home_fs" = "btrfs" ] && setup_home_subvol

if [ "$var_fs" = "btrfs" ]; then
    _create_subvol          "@flatpak"
    _migrate_subvol_data    "@flatpak" "/var/lib/flatpak" "flatpak repair || :"
    add_subvol_mount        "@flatpak" "/var/lib/flatpak"

    _create_subvol          "@libvirt-images"
    _migrate_subvol_data    "@libvirt-images" "/var/lib/libvirt/images"
    add_subvol_mount        "@libvirt-images" "/var/lib/libvirt/images"

    _create_subvol          "@cache"
    sudo find /mnt/@/var/cache -mindepth 1 -delete
    add_subvol_mount        "@cache" "/var/cache"
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

