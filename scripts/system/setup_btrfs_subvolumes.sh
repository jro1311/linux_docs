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
    red_message "Error:" "Exiting due to immutable OSTree system."
    exit 1
fi

detect_system

if [ "$root_fs" != "btrfs" ] \
    && [ "$home_fs" != "btrfs" ] \
    && [ "$var_fs" != "btrfs" ]; then

    red_message "Error:" "No btrfs filesystems detected on '/', '/home', or '/var'."
    exit 1
fi

[ -d /mnt ] || sudo mkdir -p /mnt

set -- /mnt/*
if [ -e "$1" ]; then
    red_message "Error" "'/mnt' is not empty."
    exit 1
fi

root_dev_raw="$(findmnt -no SOURCE / 2>/dev/null || :)"
root_dev="${root_dev_raw%%\[*}"

if [ -z "$root_dev" ]; then
    red_message "Error:" "Could not detect root device."
    exit 1
fi

green_message "Root Device:" "$root_dev"
confirm_proceed

sudo mount -o subvolid=5 "$root_dev" /mnt

if ! sudo btrfs subvolume show /mnt | grep -Fq "Subvolume ID: 5"; then
    red_message "Error" "/mnt is not a top-level btrfs mount (ID 5)."
    exit 1
fi

backup_path="/etc/fstab.backup.$(date +%Y%m%d-%H%M%S)"
sudo cp /etc/fstab "$backup_path"

setup_root_subvol() {
    # Case 1: Debian default (@rootfs)
    if [ -d /mnt/@rootfs ]; then
        if [ ! -d /mnt/@ ]; then
            sudo mv /mnt/@rootfs /mnt/@
            sudo sed -i '/[[:space:]]\/[[:space:]]/ s/\<subvol=@rootfs\>/subvol=@/' /etc/fstab
            green_message "Renamed:" "@rootfs -> @"
        else
            green_message "Skipped:" "@rootfs (target @ exists)"
        fi
        return
    fi

    # Case 2: Fedora default (root)
    if [ -d /mnt/root ]; then
        if [ ! -d /mnt/@ ]; then
            sudo mv /mnt/root /mnt/@
            sudo sed -i '/[[:space:]]\/[[:space:]]/ s/\<subvol=root\>/subvol=@/' /etc/fstab
            green_message "Renamed:" "root -> @"
        else
            green_message "Skipped:" "root (target @ exists)"
        fi
        return
    fi

    # Case 3: Other
    if [ ! -d /mnt/@ ]; then
        sudo btrfs subvolume create /mnt/@
        green_message "Created:" "@"
    else
        green_message "Already exists:" "@"
    fi
}

setup_home_subvol() {
    # Case 1: /mnt/home is a subvolume
    if sudo btrfs subvolume show /mnt/home >/dev/null 2>&1; then
        if [ ! -d /mnt/@home ]; then
            sudo mv /mnt/home /mnt/@home
            sudo sed -i '/[[:space:]]\/home[[:space:]]/ s/\<subvol=home\>/subvol=@home/' /etc/fstab
            green_message "Renamed:" "home -> @home"
        else
            green_message "Skipped:" "home (target @home exists)"
        fi

        return 0
    fi

    # Case 2: /mnt/home is a directory
    if [ -d /mnt/home ]; then
        if [ ! -d /mnt/@home ] || [ ! -f /mnt/@home/.migration-complete ]; then
            sudo btrfs subvolume create /mnt/@home 2>/dev/null || :
            sudo rsync -aHAXP /mnt/home/ /mnt/@home/
            sudo rm -rf /mnt/home/*
            sudo touch /mnt/@home/.migration-complete
            green_message "Migrated:" "directory home -> @home"
        else
            green_message "Skipped:" "directory home (target @home exists)"
        fi

        return 0
    fi

    # Case 3: Other
    if [ ! -d /mnt/@home ]; then
        sudo btrfs subvolume create /mnt/@home
        green_message "Created:" "@home"
    else
        green_message "Already exists:" "@home"
    fi
}

create_if_missing() {
    local path="$1"

    if [ ! -d "/mnt/$path" ]; then
        sudo btrfs subvolume create "/mnt/$path"
        green_message "Created:" "$path"
    else
        green_message "Already exists:" "$path"
    fi
}

add_subvol_mount() {
    local name="$1"
    local mountpoint="$2"

    sudo mkdir -p "$mountpoint"

    local var_dev uuid
    var_dev=$(findmnt -no SOURCE /var 2>/dev/null || :)

    if [ -n "$var_dev" ] && sudo blkid "$var_dev" | grep -q 'TYPE="btrfs"'; then
        uuid=$(sudo blkid -s UUID -o value "$var_dev")
    else
        uuid=$(sudo blkid -s UUID -o value "$root_dev")
    fi

    local template
    template=$(awk '$2 == "/var" {print; found=1} END {if (!found) exit 1}' /etc/fstab \
           || awk '$2 == "/" {print}' /etc/fstab)

    printf "%s\n" "$template" | sudo tee -a /etc/fstab >/dev/null
    sudo sed -i "\$s#^[^[:space:]]*#UUID=$uuid#" /etc/fstab

    if grep -Fq "subvol=" <<< "$template"; then
        sudo sed -i "\$s#subvol=[^, ]*#subvol=$name#" /etc/fstab
    else
        sudo sed -i "\$s#\(btrfs[[:space:]].*\)#\1,subvol=$name#" /etc/fstab
    fi

    green_message "Added:" "fstab entry for $name"
}

[ "$root_fs" = "btrfs" ] && setup_root_subvol
[ "$home_fs" = "btrfs" ] && setup_home_subvol

if [ "$var_fs" = "btrfs" ]; then
    create_if_missing "@flatpak"
    add_subvol_mount "@flatpak" "/var/lib/flatpak"

    create_if_missing "@libvirt-images"
    add_subvol_mount "@libvirt-images" "/var/lib/libvirt/images"
fi

if [ "$init_system" = "systemd" ]; then
    sudo systemctl daemon-reload
fi

sudo findmnt --verify --verbose
update_bootloader

green_message "Success:" "Subvolumes setup complete."

