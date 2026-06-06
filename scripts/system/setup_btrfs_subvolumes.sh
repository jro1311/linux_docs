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

unmount_on_error() {
    local status=$?

    if [ $status -ne 0 ] && mountpoint -q /mnt; then
        red_message "Error detected:" "Unmounting '/mnt'..."
        sudo umount /mnt
    fi

    exit $status
}

trap unmount_on_error EXIT

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

subvol_id="$(sudo btrfs subvolume show /mnt | awk '/Subvolume ID:/ {print $3}')"

if [ "$subvol_id" -ne 5 ]; then
    red_message "Error" "/mnt is not a top-level btrfs mount (ID 5)."
    exit 1
fi

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
    else
        yellow_message "Info:" "No subvolumes were created."
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
            sudo rsync -aHAXP /mnt/home/ /mnt/@home/
            sudo rm -rf /mnt/home/*
            sudo touch /mnt/@home/.migration-complete
            created_subvols+=("@home")
            migrated_dirs+=("/home -> @home")
        fi

        return 0
    fi

    # Case 3: Other
    if [ ! -d /mnt/@home ]; then
        sudo btrfs subvolume create /mnt/@home
        created_subvols+=("@home")
    fi
}

create_subvol() {
    local path="$1"

    if [ ! -d "/mnt/$path" ]; then
        sudo btrfs subvolume create "/mnt/$path"
        created_subvols+=("$path")
    fi
}

add_subvol_mount() {
    local name="$1"
    local mountpoint="$2"
    local var_dev uuid template new_entry

    sudo mkdir -p "$mountpoint"

    var_dev=$(findmnt -no SOURCE /var 2>/dev/null || :)

    if [ -n "$var_dev" ] && sudo blkid "$var_dev" | grep -q 'TYPE="btrfs"'; then
        uuid=$(sudo blkid -s UUID -o value "$var_dev")
    else
        uuid=$(sudo blkid -s UUID -o value "$root_dev")
    fi

    # Use /var as the preferred template, and / as a fallback
    template=$(awk '$2 == "/var" {print; found=1} END {if (!found) exit 1}' /etc/fstab \
           || awk '$2 == "/" {print; exit}' /etc/fstab)

    # Rewrite mountpoint and subvol into the duplicated line
    new_entry=$(echo "$template" \
        | awk -v mp="$mountpoint" -v sv="$name" -v id="$uuid" '
            {
                $1 = "UUID=" id
                $2 = mp
                found=0
                for (i=1; i<=NF; i++) {
                    if ($i ~ /subvol=/) {
                        sub(/subvol=[^, ]*/, "subvol=" sv, $i)
                        found=1
                    }
                }
                if (!found) {
                    $4 = $4 ",subvol=" sv
                }
                print
            }
        ')

    sudo sed -i "\|[[:space:]]${mountpoint}[[:space:]]|d" /etc/fstab
    echo "$new_entry" | sudo tee -a /etc/fstab >/dev/null
}

[ "$root_fs" = "btrfs" ] && setup_root_subvol
[ "$home_fs" = "btrfs" ] && setup_home_subvol

if [ "$var_fs" = "btrfs" ]; then
    create_subvol "@flatpak"
    add_subvol_mount "@flatpak" "/var/lib/flatpak"

    # Migrate only if:
    # 1. The old directory exists
    # 2. The old directory is non-empty
    # 3. The @flatpak subvolume is mounted at /var/lib/flatpak
    set -- /mnt/@/var/lib/flatpak/*
    if [ -d /mnt/@/var/lib/flatpak ] \
        && [ -e "$1" ] \
        && findmnt -no OPTIONS /var/lib/flatpak | grep -Fq "subvol=/@flatpak"; then

        sudo rsync -aHAXP /mnt/@/var/lib/flatpak/ /mnt/@flatpak
        sudo rm -rf /mnt/@/var/lib/flatpak/*
        sudo chown -R root:root /var/lib/flatpak
        flatpak repair || :

        migrated_dirs+=("/var/lib/flatpak -> @flatpak")
    fi

    create_subvol "@libvirt-images"
    sudo rm -rf /mnt/@/var/lib/libvirt/images/*
    add_subvol_mount "@libvirt-images" "/var/lib/libvirt/images"

    create_subvol "@cache"
    sudo rm -rf /mnt/@/var/cache/*
    add_subvol_mount "@cache" "/var/cache"
fi

apply_btrfs_cow_policies

var_paths=(
    /var/lib/flatpak
    /var/lib/libvirt
    /var/lib/libvirt/images
    /var/cache
)

if [ "$var_fs" = "btrfs" ]; then
    restorecon_paths "${var_paths[@]}"
fi

sudo umount /mnt

case "$init_system" in
    systemd)
        sudo systemctl daemon-reload
        ;;
esac

sudo mount -a

if ! sudo findmnt --verify --verbose; then
    confirm_proceed
fi

update_bootloader
print_summary

