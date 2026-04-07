# shellcheck shell=bash
# shellcheck source=/dev/null
# shellcheck disable=SC2034,SC2154

detect_os() {
    if [ -f /etc/os-release ]; then
        source /etc/os-release

        os="${ID:-}"
        os_like="${ID_LIKE:-$os}"

        os="${os,,}"
        os_like="${os_like,,}"
    fi
}

detect_primary_pm() {
    primary_pm=""
    primary_pms=(apt dnf eopkg pacman xbps-install zypper rpm-ostree)

    local cmd=""
    for cmd in "${primary_pms[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            primary_pm="$cmd"
            break
        fi
    done

    case "$primary_pm" in
        "xbps-install")
            primary_pm="xbps"
            ;;
    esac
}

detect_secondary_pm() {
    secondary_pm=""
    secondary_pms=(nala paru yay)

    local cmd=""
    for cmd in "${secondary_pms[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            secondary_pm="$cmd"
            break
        fi
    done
}

detect_alt_pms() {
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
    bootloader=""
    update_bootloader=""
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
    root_fs="$(df -T / | awk 'NR==2 {print $2}')"
    home_fs="$(df -T /home | awk 'NR==2 {print $2}')"
}

detect_swapfile() {
    swap_detected=0
    swap_path=""
    fstab_pattern=""

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

detect_desktop() {
    desktop=$(echo "${XDG_CURRENT_DESKTOP:-}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')
}

detect_display() {
    local display_cmd=""
    if command -v xrandr >/dev/null 2>&1; then
        display_cmd="xrandr"
    elif command -v wlr-randr >/dev/null 2>&1; then
        display_cmd="wlr-randr"
    fi

    if [ -n "$display_cmd" ]; then
        display="$("$display_cmd" | grep "primary" -A1 | tail -1 | awk '{print $1}')"
        display_w="$(echo "$display" | cut -d'x' -f1)"
        display_h="$(echo "$display" | cut -d'x' -f2)"
        refresh_rate="$("$display_cmd"  | grep "primary" -A1 | tail -1 | awk '{print $2}' | sed 's/[*+]//g' | xargs printf "%.0f")"
        max_fps_target="$(awk "BEGIN {printf \"%.0f\", int(($refresh_rate - 5) / 5 + 0.5) * 5}")"
    fi
}

detect_gpu() {
    gpu_info=$(lspci | grep -E "VGA|3D")
}

detect_network_interface() {
    network_interface="$(ip route get 1.1.1.1 2>/dev/null | awk '/dev/ {print $5; exit}')"
}

detect_battery() {
    battery_detected=0
    if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
        battery_detected=1
    fi
}

detect_system() {
    [[ -n "${system_info_initialized:-}" ]] && return 0
    detect_os
    detect_primary_pm
    detect_secondary_pm
    detect_alt_pms
    detect_init_system
    detect_bootloader
    detect_filesystems
    detect_swapfile
    detect_desktop
    detect_display
    detect_gpu
    detect_network_interface
    detect_battery
    system_info_initialized=1
}
