# shellcheck shell=bash
# shellcheck source=/dev/null
# shellcheck disable=SC2034,SC2154

detect_host_system() {
    shopt -s nullglob

    host_system="unknown"
    batteries=(/sys/class/power_supply/BAT*)

    if (( ${#batteries[@]} )); then
        host_system="laptop"
    else
        host_system="desktop"
    fi

    shopt -u nullglob
}

detect_os() {
    if [ -f /etc/os-release ]; then
        source /etc/os-release

        os="${ID:-unknown}"
        os_like="${ID_LIKE:-$os}"

        os="${os,,}"
        os_like="${os_like,,}"

        debian_version="0"
        ubuntu_version="0"
        linuxmint_version="0"
        fedora_version="0"
        openmandriva_version="0"
        opensuse_version="0"

        case "$os" in
            "debian")
                debian_version="${VERSION_ID-:0}"
                ;;
            "ubuntu")
                ubuntu_version="${VERSION_ID-:0}"
                ;;
            "linuxmint")
                linuxmint_version="${VERSION_ID:-0}"
                ;;
            "fedora")
                fedora_version="${VERSION_ID-:0}"
                ;;
            "openmandriva")
                openmandriva_version="${VERSION_ID-:0}"
                ;;
            "opensuse-leap")
                opensuse_version="${VERSION_ID-:0}"
                ;;
            *)
                case "$os_like" in
                    "debian")
                        debian_version="${VERSION_ID-:0}"
                        ;;
                    "ubuntu debian")
                        ubuntu_version="${VERSION_ID-:0}"
                        ;;
                    "fedora")
                        fedora_version="${VERSION_ID-:0}"
                        ;;
                esac
                ;;
        esac
    fi
}

detect_package_managers() {
    primary_package_manager="unknown"
    secondary_package_manager="unknown"

    primary_package_managers=(apt dnf eopkg pacman xbps-install zypper rpm-ostree)
    secondary_package_managers=(nala paru yay)

    for cmd in "${primary_package_managers[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            primary_package_manager="$cmd"
            break
        fi
    done

    for cmd in "${secondary_package_managers[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            secondary_package_manager="$cmd"
            break
        fi
    done

    if [ "$primary_package_manager" = "xbps-install" ]; then
        primary_package_manager="xbps"
    fi

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

detect_desktop() {
    desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')
}

detect_init_system() {
    init_system="unknown"
    pid1_comm=$(ps -p 1 -o comm=)

    case "$pid1_comm" in
        "systemd"|"dinit"|"runit")
            init_system="$pid1_comm"
            ;;
        "openrc-init")
            init_system="openrc"
            ;;
        "s6-linux-init")
            init_system="s6"
            ;;
        "init")
            init_system="sysvinit"
            ;;
    esac
}

detect_bootloader() {
    bootloader="unknown"
    update_bootloader="unknown"

    if command -v update-grub >/dev/null 2>&1 || command -v /usr/sbin/update-grub >/dev/null 2>&1; then
        bootloader="grub"
        update_bootloader="update-grub"

    elif command -v grub2-mkconfig >/dev/null 2>&1; then
        bootloader="grub"
        update_bootloader="grub2-mkconfig -o /boot/grub2/grub.cfg"

    elif command -v grub-mkconfig >/dev/null 2>&1; then
        bootloader="grub"
        update_bootloader="grub-mkconfig -o /boot/grub/grub.cfg"

    elif command -v limine-update >/dev/null 2>&1; then
        bootloader="limine"
        update_bootloader="limine-update"

    elif find /boot/efi/EFI -name "*systemd-boot*.efi" >/dev/null 2>&1; then
        bootloader="systemd-boot"
        update_bootloader="bootctl update"
    fi
}

detect_filesystems() {
    root_filesystem="$(df -T / | awk 'NR==2 {print $2}')"
    home_filesystem="$(df -T /home | awk 'NR==2 {print $2}')"
}

detect_gpu() {
    gpu_info=$(lspci | grep -E "VGA|3D")
}

detect_display() {
    display_cmd="unknown"
    if command -v xrandr >/dev/null 2>&1; then
        display_cmd="xrandr"
    elif command -v wlr-randr >/dev/null 2>&1; then
        display_cmd="wlr-randr"
    fi

    if [ "$display_cmd" != "unknown" ]; then
        display="$("$display_cmd" | grep "primary" -A1 | tail -1 | awk '{print $1}')"
        display_w="$(echo "$display" | cut -d'x' -f1)"
        display_h="$(echo "$display" | cut -d'x' -f2)"
        refresh_rate="$("$display_cmd"  | grep "primary" -A1 | tail -1 | awk '{print $2}' | sed 's/[*+]//g' | xargs printf "%.0f")"
        max_fps_target="$(awk "BEGIN {printf \"%.0f\", int(($refresh_rate - 5) / 5 + 0.5) * 5}")"
    fi
}

detect_network_interface() {
    network_interface="$(ip route get 1.1.1.1 2>/dev/null | awk '/dev/ {print $5; exit}')" || true
    [ -z "$network_interface" ] && network_interface=""
}

detect_swapfile() {
    swap_detected=0
    swap_path=""
    fstab_pattern=""
    swap_is_btrfs_subvol=0

    if [ -f /swapfile ]; then
        swap_detected=1
        swap_path="/swapfile"
        fstab_pattern="/swapfile"
        return 0

    elif [ -f /swap/swapfile ]; then
        swap_detected=1
        swap_path="/swap/swapfile"
        fstab_pattern="/swap/swapfile"
        return 0

    elif [ -f /swap.img ]; then
        swap_detected=1
        swap_path="/swap.img"
        fstab_pattern="/swap.img"
        return 0
    fi
}

detect_system() {
    [[ -n "${system_info_initialized:-}" ]] && return 0
    detect_host_system
    detect_os
    detect_package_managers
    detect_desktop
    detect_init_system
    detect_bootloader
    detect_filesystems
    detect_gpu
    detect_display
    detect_network_interface
    detect_swapfile
    system_info_initialized=1
}
