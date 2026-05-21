# shellcheck shell=bash
# shellcheck disable=SC2018,SC2019,SC2034,SC2154

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release

        os="${ID:-}"
        os_like="${ID_LIKE:-$os}"

        os=$(printf '%s' "$os" | tr 'A-Z' 'a-z')
        os_like=$(printf '%s' "$os_like" | tr 'A-Z' 'a-z')

        # Normalize whitespace
        os_like=$(printf '%s' "$os_like" | tr -s ' ')
    fi
}

detect_primary_pm() {
    primary_pm=""

    local -a primary_pms=(
        apt
        dnf
        eopkg
        pacman
        xbps-install
        zypper
        rpm-ostree
    )

    local cmd=""
    for cmd in "${primary_pms[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            primary_pm="$cmd"
            break
        fi
    done

    case "$primary_pm" in
        xbps-install)
            primary_pm="xbps"
            ;;
    esac
}

detect_secondary_pm() {
    secondary_pm=""

    local -a secondary_pms=(
        nala
        paru
        yay
    )

    local cmd=""
    for cmd in "${secondary_pms[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            secondary_pm="$cmd"
            break
        fi
    done
}

detect_optionals() {
    flatpak_installed=0
    if command -v flatpak >/dev/null 2>&1; then
        flatpak_installed=1
    fi

    snap_installed=0
    if command -v snap >/dev/null 2>&1; then
        snap_installed=1
    fi

    toolbox_installed=0
    if command -v toolbox >/dev/null 2>&1 || command -v podman-toolbox >/dev/null 2>&1; then
        toolbox_installed=1
    fi
}

detect_init_system() {
    init_system=""

    local pid1_comm
    pid1_comm=$(ps -p 1 -o comm=)

    case "$pid1_comm" in
        systemd|dinit|runit)
            init_system="$pid1_comm"
            ;;
        openrc-init)
            init_system="openrc"
            ;;
        s6-linux-init)
            init_system="s6"
            ;;
        init)
            init_system="sysvinit"
            ;;
    esac
}

detect_initramfs() {
    initramfs_backend=""
    initramfs_cmd=""
    initramfs_args=""

    if command -v dracut >/dev/null 2>&1; then
        initramfs_backend="dracut"
        initramfs_cmd="dracut"
        initramfs_args="--force"

    elif command -v update-initramfs >/dev/null 2>&1; then
        initramfs_backend="update-initramfs"
        initramfs_cmd="update-initramfs"
        initramfs_args="-u -k $(uname -r)"

    elif command -v mkinitcpio >/dev/null 2>&1; then
        initramfs_backend="mkinitcpio"
        initramfs_cmd="mkinitcpio"
        initramfs_args="-P"

    elif command -v xbps-reconfigure >/dev/null 2>&1; then
        initramfs_backend="xbps"
        initramfs_cmd="xbps-reconfigure"
        initramfs_args="-f linux"

    elif command -v mkinitfs >/dev/null 2>&1; then
        initramfs_backend="mkinitfs"
        initramfs_cmd="mkinitfs"
        initramfs_args=""
    fi
}

detect_bootloader() {
    bootloader=""
    update_bootloader_cmd=""
    update_bootloader_args=""

    if command -v update-grub >/dev/null 2>&1 ||
        command -v /usr/sbin/update-grub >/dev/null 2>&1; then
        bootloader="grub"
        update_bootloader_cmd="update-grub"

    elif command -v grub2-mkconfig >/dev/null 2>&1; then
        bootloader="grub"
        update_bootloader_cmd="grub2-mkconfig"
        update_bootloader_args="-o /boot/grub2/grub.cfg"

    elif command -v grub-mkconfig >/dev/null 2>&1; then
        bootloader="grub"
        update_bootloader_cmd="grub-mkconfig"
        update_bootloader_args="-o /boot/grub/grub.cfg"

    elif command -v limine-update >/dev/null 2>&1; then
        bootloader="limine"
        update_bootloader_cmd="limine-update"

    elif [ -e /boot/efi/EFI/refind/refind_x64.efi ]; then
        bootloader="refind"
        if command -v refind-install >/dev/null 2>&1; then
            update_bootloader_cmd="refind-install"
        fi

    elif command -v bootctl >/dev/null 2>&1; then
        bootloader="systemd-boot"
        update_bootloader_cmd="bootctl"
        update_bootloader_args="update"
    fi
}

detect_filesystems() {
    root_fs="$(df -T / | awk 'NR==2 {print $2}')"
    home_fs="$(df -T /home | awk 'NR==2 {print $2}')"

    local -a file_systems=(
        bcachefs
        btrfs
        ext4
        f2fs
        xfs
        apfs
        exfat
        ntfs
        vfat
        zfs
    )

    fs_detected_list=()

    local fs=""
    for fs in "${file_systems[@]}"; do
        printf -v "${fs}_detected" 0
    done

    local mounts
    mounts=$(cat /proc/mounts)

    for fs in "${file_systems[@]}"; do
        case "$mounts" in
            *" $fs "*)
                printf -v "${fs}_detected" 1
                fs_detected_list+=("$fs")
                ;;
        esac
    done
}

detect_swap_partition() {
    swap_partition_exists=0
    swap_partition_path=""

    while read -r path type _; do
        case "$path" in
            /dev/zram*) continue ;;
        esac

        [ "$type" = "partition" ] || continue
        [ -b "$path" ] || continue

        swap_partition_exists=1
        swap_partition_path="$path"
    done < /proc/swaps
}

detect_swapfile() {
    swapfile_exists=0
    swapfile_path=""

    if [ -f /swapfile ]; then
        swapfile_exists=1
        swapfile_path=/swapfile

    elif [ -f /swap/swapfile ]; then
        swapfile_exists=1
        swapfile_path=/swap/swapfile

    elif [ -f /swap.img ]; then
        swapfile_exists=1
        swapfile_path=/swap.img
    fi
}

detect_ram() {
    ram_bytes=$(free -b | awk '/^Mem:/ {print $2}')

    ram_kib=$(( ram_bytes / 1024 ))
    ram_mib=$(( ram_bytes / 1024 / 1024 ))
    ram_gib=$(( ram_bytes / 1024 / 1024 / 1024 ))
}

detect_gpu() {
    local gpu_info
    local -a gpu_vendors=(
        amd
        nvidia
        intel
    )

    gpu_info=$(lspci | grep -E "VGA|3D")
    gpu_detected_list=()

    for brand in "${gpu_vendors[@]}"; do
        printf -v "${brand}_gpu_detected" 0
    done

    for brand in "${gpu_vendors[@]}"; do
        if echo "$gpu_info" | grep -Fiq "$brand"; then
            printf -v "${brand}_gpu_detected" 1
            gpu_detected_list+=("$brand")
        fi
    done
}

detect_network_interface() {
    network_interface="$(
        ip route get 1.1.1.1 2>/dev/null |
            awk '/dev/ {print $5; found=1} END {exit !found}' ||
        ip route show default 2>/dev/null |
            awk '/default/ {print $5; exit}' ||
        true
    )"
}

detect_battery() {
    battery_detected=0
    if compgen -G "/sys/class/power_supply/BAT*" >/dev/null 2>&1; then
        battery_detected=1
    fi
}

detect_optical_drive() {
    optical_drive_detected=0
    if [ -e /dev/sr0 ]; then
        optical_drive_detected=1
    fi
}

detect_desktop() {
    desktop=$(echo "${XDG_CURRENT_DESKTOP:-}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')
}

detect_display() {
    local display_cmd=""
    display=""
    display_w=""
    display_h=""
    refresh_rate=""
    max_fps_target=""

    if command -v xrandr >/dev/null 2>&1; then
        display_cmd="xrandr"
    elif command -v wlr-randr >/dev/null 2>&1; then
        display_cmd="wlr-randr"
    fi

    if [ -n "$display_cmd" ]; then
        display="$(
            "$display_cmd" \
                | { grep -E '\bprimary\b' -A1 || :; } \
                | tail -1 \
                | awk '{print $1}'
        )"

        if [ -z "$display" ]; then
            display="$(
                "$display_cmd" \
                    | { grep -E '\bconnected\b' -A1 || :; } \
                    | tail -1 \
                    | awk '{print $1}'
            )"
        fi

        case "$display" in
            *x*) ;;
            *) return 0 ;;
        esac

        display_w="${display%x*}"
        display_h="${display#*x}"

        refresh_rate="$(
            "$display_cmd" \
                | grep "$display" -A1 \
                | tail -1 \
                | awk '{print $2}' \
                | sed 's/[*+]//g' \
                | xargs printf "%.0f"
        )"

        max_fps_target="$(awk "BEGIN {printf \"%.0f\", int(($refresh_rate - 5) / 5 + 0.5) * 5}")"
    fi
}

detect_system() {
    [ -n "${system_info_initialized:-}" ] && return 0

    detect_os

    detect_primary_pm
    detect_secondary_pm
    detect_optionals

    detect_init_system
    detect_initramfs
    detect_bootloader

    detect_filesystems
    detect_swap_partition
    detect_swapfile

    detect_ram
    detect_gpu
    detect_network_interface
    detect_battery
    detect_optical_drive

    detect_desktop
    detect_display

    system_info_initialized=1
}

define_compression_algorithm() {
    [ -n "${comp_algo_initialized:-}" ] && return 0

    blue_message "Calculating:" "Optimal compression algorithm..."

    local zstd_speed_raw zstd_speed

    zstd_speed_raw=$(zstd -b --fast=1 2>/dev/null \
        | grep -oE '[0-9]+\.[0-9]+ MB/s' \
        | head -n1 \
    )

    zstd_speed=${zstd_speed_raw%%.*}

    if [ -n "$zstd_speed" ] && [ "$zstd_speed" -ge 200 ]; then
        comp_algo="zstd"
    else
        comp_algo="lz4"
    fi

    comp_algo_initialized=1
}

define_network_speeds() {
    [ -n "${net_speeds_initialized:-}" ] && return 0

    if ! command -v speedtest-cli >/dev/null 2>&1; then
        red_message "Error:" "speedtest-cli not detected."
        return 1
    fi

    blue_message "Calculating:" "Network speeds..."

    local out down_raw up_raw down_i up_i diff

    out=$(speedtest-cli)

    if [ -z "$out" ]; then
        red_message "Error:" "No output from speedtest."
        return 1
    fi

    down_raw=$(printf "%s" "$out" | awk '/Download:/ {print $2}')
    up_raw=$(printf "%s" "$out" | awk '/Upload:/ {print $2}')

    down_i=${down_raw%%.*}
    up_i=${up_raw%%.*}

    # Round to the nearest 10
    download_speed_mb=$(( (down_i + 5) / 10 * 10 ))
    upload_speed_mb=$(( (up_i + 5) / 10 * 10 ))

    # Equalize if difference is 10 or less
    diff=$(( download_speed_mb - upload_speed_mb ))
    if [ ${diff#-} -le 10 ]; then
        if [ "$download_speed_mb" -ge "$upload_speed_mb" ]; then
            upload_speed_mb=$download_speed_mb
        else
            download_speed_mb=$upload_speed_mb
        fi
    fi

    [ "$download_speed_mb" -eq 0 ] && download_speed_mb=5
    [ "$upload_speed_mb" -eq 0 ] && upload_speed_mb=5

    net_speeds_initialized=1
}
