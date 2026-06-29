# shellcheck shell=bash
# shellcheck disable=SC2018,SC2019,SC2034,SC2154

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release

        os="${ID:-}"
        os_like="${ID_LIKE:-$os}"
        os_label="${NAME:-$ID}"

        os=$(printf '%s' "$os" | tr 'A-Z' 'a-z')
        os_like=$(printf '%s' "$os_like" | tr 'A-Z' 'a-z')

        # Normalize whitespace
        os=$(printf '%s' "$os" | tr -s ' ')
        os_like=$(printf '%s' "$os_like" | tr -s ' ')
        os_label=$(printf '%s' "$os_label" | tr -s ' ')
    fi
}

detect_primary_pm() {
    primary_pm=""

    local cmd=""
    local -a primary_pms=(
        apt
        dnf
        eopkg
        pacman
        xbps-install
        zypper
        rpm-ostree
    )

    for cmd in "${primary_pms[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            primary_pm="$cmd"
            break
        fi
    done

    case "$primary_pm" in
        xbps-install) primary_pm="xbps" ;;
    esac
}

detect_secondary_pm() {
    secondary_pm=""

    local cmd=""
    local -a secondary_pms=(
        nala
        yay
        paru
        pikaur
        aura
    )

    for cmd in "${secondary_pms[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            secondary_pm="$cmd"
            break
        fi
    done
}

detect_optionals() {
    flatpak_installed=0
    snap_installed=0
    toolbox_installed=0

    if command -v flatpak >/dev/null 2>&1; then
        flatpak_installed=1
    fi

    if command -v snap >/dev/null 2>&1; then
        snap_installed=1
    fi

    if command -v toolbox >/dev/null 2>&1 || command -v podman-toolbox >/dev/null 2>&1; then
        toolbox_installed=1
    fi
}

detect_init_system() {
    init_system=""

    local pid1_comm
    pid1_comm=$(ps -p 1 -o comm=)

    case "$pid1_comm" in
        systemd)
            init_system="systemd"
            init_system_label="Systemd"
            ;;
        dinit)
            init_system="dinit"
            init_system_label="Dinit"
            ;;
        runit)
            init_system="runit"
            init_system_label="Runit"
            ;;
        openrc-init)
            init_system="openrc"
            init_system_label="OpenRC"
            ;;
        s6-linux-init)
            init_system="s6"
            init_system_label="s6"
            ;;
        init)
            init_system="sysvinit"
            init_system_label="SysVinit"
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

    case "$bootloader" in
        grub)           bootloader_label="GRUB" ;;
        limine)         bootloader_label="Limine" ;;
        refind)         bootloader_label="rEFInd" ;;
        systemd-boot)   bootloader_label="Systemd-Boot" ;;
    esac
}

detect_boot_mode() {
    if [ -d /sys/firmware/efi ]; then
        boot_mode="uefi"
        boot_mode_label="UEFI"
    else
        boot_mode="bios"
        boot_mode_label="Legacy BIOS"
    fi
}

detect_filesystems() {
    root_fs=$(findmnt -no FSTYPE -T /)
    var_fs=$(findmnt -no FSTYPE -T /var)
    home_fs=$(findmnt -no FSTYPE -T /home)
    tmp_fs=$(findmnt -no FSTYPE -T /tmp)

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

    local -a mounted_fs
    mapfile -t mounted_fs < <(findmnt -nro FSTYPE | sort -u)

    for fs in "${file_systems[@]}"; do
        if printf '%s\n' "${mounted_fs[@]}" | grep -Fxq "$fs"; then
            printf -v "${fs}_detected" 1
            fs_detected_list+=("$fs")
        fi
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

detect_boot_drive() {
    local boot_src parent_dev

    boot_src="$(findmnt -no SOURCE /)"
    boot_src="${boot_src%%[*}"

    case "$boot_src" in
        /dev/nvme*)
            boot_drive="nvme_ssd"
            boot_drive_label="NVMe SSD"
            ;;
        /dev/mmcblk*)
            boot_drive="emmc"
            boot_drive_label="eMMC"
            ;;
        *)
            parent_dev="$(basename "$boot_src")"
            parent_dev="${parent_dev%%[0-9]*}"

            if [ -e "/sys/block/$parent_dev/queue/rotational" ]; then
                boot_drive="hdd"
                boot_drive_label="HDD"
            else
                boot_drive="sata_ssd"
                boot_drive_label="SATA SSD"
            fi
            ;;
    esac
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
    desktop=$(printf '%s' "${XDG_CURRENT_DESKTOP:-}" \
        | cut -d ':' -f1 \
        | tr '[:upper:]' '[:lower:]')

    case "$desktop" in
        x-cinnamon)     desktop="cinnamon" ;;
        ubuntu)         desktop="gnome" ;;
        kde)            desktop="plasma" ;;
    esac

    case "$desktop" in
        gnome)          desktop_label="GNOME" ;;
        cosmic)         desktop_label="COSMIC" ;;
        cinnamon)       desktop_label="Cinnamon" ;;
        mate)           desktop_label="MATE" ;;
        xfce)           desktop_label="Xfce" ;;
        lxde)           desktop_label="LXDE" ;;
        budgie)         desktop_label="Budgie" ;;
        pantheon)       desktop_label="Pantheon" ;;
        unity)          desktop_label="Unity" ;;
        deepin)         desktop_label="Deepin" ;;
        plasma)         desktop_label="KDE Plasma" ;;
        lxqt)           desktop_label="LXQt" ;;
        awesome)        desktop_label="Awesome" ;;
        enlightenment)  desktop_label="Enlightenment" ;;
        fluxbox)        desktop_label="Fluxbox" ;;
        hyprland)       desktop_label="Hyprland" ;;
        i3)             desktop_label="i3" ;;
        openbox)        desktop_label="Openbox" ;;
        qtile)          desktop_label="Qtile" ;;
        sway)           desktop_label="Sway" ;;
        xmonad)         desktop_label="XMonad" ;;
        *)              desktop_label="$desktop" ;;
    esac
}

detect_display() {
    display=""
    display_w=""
    display_h=""
    refresh_rate=""
    max_fps_target=""

    command -v xrandr >/dev/null 2>&1 || return 0

    display="$(xrandr | awk '
        / primary / {p=1; next}
        p && /^[[:space:]]*[0-9]+x[0-9]+/ {print $1; exit}

        / connected / {c=1; next}
        c && /^[[:space:]]*[0-9]+x[0-9]+/ && !done {
            print $1
            done=1
        }
    ')"

    [ -z "$display" ] && return 0

    case "$display" in
        *x*) ;;
        *) return 0 ;;
    esac

    display_w="${display%x*}"
    display_h="${display#*x}"

    refresh_rate="$(xrandr | awk -v mode="$display" '
        $0 ~ mode {m=1; next}
        m && /^[[:space:]]*[0-9]+x[0-9]+/ {
            gsub(/[*+]/, "", $2)
            printf "%.0f", $2
            exit
        }
    ')"

    max_fps_target=$((refresh_rate - 5))
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
    detect_boot_mode

    detect_filesystems
    detect_swap_partition
    detect_swapfile

    detect_ram
    detect_boot_drive
    detect_gpu
    detect_network_interface
    detect_battery
    detect_optical_drive

    detect_desktop
    detect_display

    system_info_initialized=1
}
