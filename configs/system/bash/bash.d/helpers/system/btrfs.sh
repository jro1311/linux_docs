# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

unmount_on_error() {
    local status=$?

    if [ $status -ne 0 ] && mountpoint -q /mnt; then
        red_message "Error detected:" "Unmounting '/mnt'..."
        sudo umount /mnt
    fi

    return $status
}

mount_root_dev() {
    [ -d /mnt ] || sudo mkdir -p /mnt

    if [ -n "$(find /mnt -mindepth 1 -print -quit 2>/dev/null)" ]; then
        red_message "Error:" "'/mnt' is not empty."
        return 1
    fi

    root_dev_raw="$(findmnt -no SOURCE / 2>/dev/null || :)"
    root_dev="${root_dev_raw%%\[*}"

    if [ -z "$root_dev" ]; then
        red_message "Error:" "Could not determine root device."
        return 1
    fi

    sudo mount -o subvolid=5 "$root_dev" /mnt

    subvol_id="$(sudo btrfs subvolume show /mnt | awk '/Subvolume ID:/ {print $3}')"

    if [ "$subvol_id" -ne 5 ]; then
        red_message "Error:" "'/mnt' is not a top-level btrfs mount (ID 5)."
        return 1
    fi
}

_create_subvol() {
    local path="$1"

    if [ ! -d "/mnt/$path" ]; then
        sudo btrfs subvolume create "/mnt/$path"
        created_subvols+=("$path")
    fi
}

_migrate_dir_data() {
    local name="$1"
    local mountpoint="$2"
    local post_cmd="${3:-}"

    local old_dir="/mnt/@${mountpoint}"
    local new_dir="/mnt/${name}"

    # Migrate only if:
    # 1. The old directory exists
    # 2. The old directory is non-empty
    # 3. The subvolume is mounted at the target mount point
    if [ -d "$old_dir" ] \
        && [ -n "$(find "$old_dir" -mindepth 1 -print -quit 2>/dev/null)" ] \
        && findmnt -no OPTIONS "$mountpoint" | grep -Fq "subvol=/$name"; then

        if sudo rsync -aHAXP "$old_dir/" "$new_dir/"; then
            sudo find "$old_dir" -mindepth 1 -delete
            [ -n "$post_cmd" ] && sh -c "$post_cmd"
            migrated_dirs+=("$mountpoint -> $name")
        fi
    fi
}

add_subvol_mount() {
    local name="$1"
    local mountpoint="$2"
    local uuid template new_entry normalized_new_entry existing_mount normalized_existing_mount

    sudo mkdir -p "$mountpoint"

    uuid=$(findmnt -no UUID /var 2>/dev/null || findmnt -no UUID / 2>/dev/null)

    if [ -z "$uuid" ]; then
        red_message "Error:" "Could not determine UUID for '$mountpoint'."
        return 1
    fi

    # Prefer non-commented /var entry, fallback to non-commented /
    template=$(awk '$1 !~ /^#/ && $2 == "/var" {print; found=1; exit} END {if (!found) exit 1}' /etc/fstab \
            || awk '$1 !~ /^#/ && $2 == "/" {print; exit}' /etc/fstab)

    # Rewrite mountpoint and subvol
    new_entry=$(echo "$template" \
        | awk -v mp="$mountpoint" -v sv="$name" -v id="$uuid" '
            $1 !~ /^#/ {
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

    # Normalize new entry (collapse whitespace)
    normalized_new_entry=$(echo "$new_entry" | awk '{$1=$1; print}')

    # Ignore commented lines when looking for existing mounts
    existing_mount=$(awk -v mp="$mountpoint" '$1 !~ /^#/ && $2 == mp {print}' /etc/fstab)

    if [ -n "$existing_mount" ]; then
        normalized_existing_mount=$(echo "$existing_mount" | awk '{$1=$1; print}')

        if [ "$normalized_new_entry" = "$normalized_existing_mount" ]; then
            yellow_message "Skipped:" "Existing fstab entry for '$mountpoint' matches exactly."
            return 0
        fi

        # Remove existing mount entry (ignoring commented ones)
        sudo sed -i -E "\|^[[:space:]]*[^#[:space:]]+[[:space:]]+${mountpoint}[[:space:]]|d" /etc/fstab
    fi

    echo "$new_entry" | sudo tee -a /etc/fstab >/dev/null
}
