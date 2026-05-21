# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

print_os() {
    if [ "$os_like" != "$os" ]; then
        print_field "Base Distro(s)" "$os_like"
    fi

    print_field "Distro" "$os"
    print_field "Version" "$VERSION_ID"
}

print_primary_pm() {
    print_field "Primary Package Manager" "$primary_pm"
}

print_secondary_pm() {
    print_field "Secondary Package Manager" "$secondary_pm"
}

print_optionals() {
    local opt
    local optionals=(
        flatpak
        snap
        toolbox
    )

    for opt in "${optionals[@]}"; do
        local var="${opt}_installed"

        if [ -v "$var" ] && [ "${!var}" -eq 1 ]; then
            print_field "${opt^} Detected" "Yes"
        else
            print_field "${opt^} Detected" "No"
        fi
    done
}

print_init_system() {
    print_field "Init System" "$init_system"
}

print_bootloader() {
    print_field "Bootloader" "$bootloader"
}

print_initramfs() {
    print_field "Initramfs" "$initramfs_backend"
}

print_filesystems() {
    fs_detected_csv="$(printf '%s, ' "${fs_detected_list[@]}")"
    fs_detected_csv="${fs_detected_csv%, }"

    print_field "Partition(s)" "$fs_detected_csv"
    print_field "Root File System" "$root_fs"
    print_field "Home File System" "$home_fs"
}

print_swap_partition() {
    if [ "$swap_partition_exists" -eq 1 ]; then
        print_field "Swap Partition" "Yes"
    else
        print_field "Swap Partition" "No"
    fi
}

print_swapfile() {
    if [ "$swapfile_exists" -eq 1 ]; then
        print_field "Swapfile" "Yes"
    else
        print_field "Swapfile" "No"
    fi
}

print_ram() {
    local ram_gib_decimal
    ram_gib_decimal=$(awk -v b="$ram_bytes" 'BEGIN { printf "%.1f", b / (1024*1024*1024) }')

    print_field "RAM" "${ram_gib_decimal} GiB"
}

print_gpu() {
    gpu_detected_csv="$(printf '%s, ' "${gpu_detected_list[@]}")"
    gpu_detected_csv="${gpu_detected_csv%, }"

    print_field "GPU(s)" "$gpu_detected_csv"
}

print_network_interface() {
    print_field "Network Interface" "$network_interface"
}

print_battery() {
    if [ "$battery_detected" -eq 1 ]; then
        print_field "Battery Detected" "Yes"
    else
        print_field "Battery Detected" "No"
    fi
}

print_optical_drive() {
    if [ "$optical_drive_detected" -eq 1 ]; then
        print_field "Optical Drive Detected" "Yes"
    else
        print_field "Optical Drive Detected" "No"
    fi
}

print_desktop() {
    print_field "Desktop" "$desktop"
}

print_display() {
    print_field "Display Resolution" "$display"
    print_field "Display Refresh Rate" "$refresh_rate Hz"
    print_field "Max FPS Target" "$max_fps_target FPS"
}

print_header() {
    if [ "$first_header_printed" -eq 1 ]; then
        printf '\n'
    fi

    printf '== %s ==\n' "$1"
    first_header_printed=1
}

print_system_info() {
    first_header_printed=0
    detect_system

    print_header "OS"
    print_os

    print_header "Package Managers"
    print_primary_pm
    print_secondary_pm
    print_optionals

    print_header "Init & Boot"
    print_init_system
    print_initramfs
    print_bootloader

    print_header "Storage"
    print_filesystems
    print_swap_partition
    print_swapfile

    print_header "Hardware"
    print_ram
    print_gpu
    print_network_interface
    print_battery
    print_optical_drive

    print_header "Desktop & Display"
    print_desktop
    print_display
}

print_compression_algorithm() {
    print_field "Compression Algorithm" "$comp_algo"
}

print_network_speeds() {
    local download_speed_mib upload_speed_mib
    download_speed_mib=$(awk "BEGIN {printf \"%.2f\", $download_speed_mb * 119209 / 1000000}")
    upload_speed_mib=$(awk "BEGIN {printf \"%.2f\", $upload_speed_mb * 119209 / 1000000}")

    print_field "Download Speed" "$download_speed_mb Mbps ($download_speed_mib MiB/s)"
    print_field "Upload Speed"   "$upload_speed_mb Mbps ($upload_speed_mib MiB/s)"
}

announce_upgrade() {
    local pm="$1"
    green_message "$pm:" "upgrading pkgs"
}

announce_clean() {
    local pm="$1"
    green_message "$pm:" "cleaning pkgs"
}

announce_list() {
    local pm="$1"
    green_message "$pm:" "listing pkgs"
}

announce_list_locked() {
    local pm="$1"
    green_message "$pm:" "listing locked pkgs"
}

announce_search() {
    local pm="$1"
    local pkg="$2"
    green_message "$pm:" "searching for '$pkg'"
}

announce_install() {
    local pm="$1"
    local pkg="$2"
    green_message "$pm:" "installing '$pkg'"
}

announce_remove() {
    local pm="$1"
    local pkg="$2"
    green_message "$pm:" "removing '$pkg'"
}

announce_lock() {
    local pm="$1"
    local pkg="$2"
    green_message "$pm:" "locking '$pkg'"
}

announce_unlock() {
    local pm="$1"
    local pkg="$2"
    green_message "$pm:" "unlocking '$pkg'"
}

announce_initramfs_rebuild() {
    local initramfs_backend="$1"
    green_message "$initramfs_backend:" "rebuilding"
}

announce_bootloader_update() {
    local bootloader="$1"
    green_message "$bootloader:" "updating"
}

unsupported_operating_system() {
    red_message "Error:" "Unsupported operating system."
}

unsupported_pkg_manager() {
    red_message "Error:" "Unsupported pkg manager."
}

unsupported_desktop() {
    red_message "Error:" "Unsupported desktop."
}

unsupported_session_type() {
    red_message "Error:" "Unsupported session type."
}

unsupported_init_system() {
    red_message "Error:" "Unsupported init system."
}

unsupported_bootloader() {
    red_message "Error:" "Unsupported bootloader."
}

reboot_required() {
    local pkgs=("$@")
    for pkg in "${pkgs[@]}"; do
        yellow_message "Reboot required:" "Reboot to use '$pkg'."
    done
}

manual_install_required() {
    local pkg="$1"
    local url="${2:-}"
    yellow_message "Manual installation required:" "$pkg"
    [ -n "$url" ] && blue_message "Download:" "$url"
}

no_function_available() {
    local pm="$1"
    yellow_message "$pm:" "no function available"
}

no_pkg_available() {
    local pm="$1"
    local pkg="$2"
    yellow_message "$pm:" "Package '$pkg' not available."
}

no_pkg_found() {
    local pm="$1"
    local pkg="$2"
    yellow_message "$pm:" "no matches found for '$pkg'" >&2
}

info_trailing_slash_mismatch() {
    blue_message "Info:" "/path/to/directory != /path/to/directory/"
}
