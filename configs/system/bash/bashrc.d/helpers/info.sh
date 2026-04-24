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
            print_field "Detected" "$opt"
        fi
    done
}

print_init_system() {
    print_field "Init System" "$init_system"
}

print_bootloader() {
    print_field "Bootloader" "$bootloader"
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
        print_field "Detected" "Swap partition"
    fi
}

print_swapfile() {
    if [ "$swapfile_exists" -eq 1 ]; then
        print_field "Detected" "Swapfile"
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
        print_field "Detected" "Battery"
    fi
}

print_optical_drive() {
    if [ "$optical_drive_detected" -eq 1 ]; then
        print_field "Detected" "Optical drive"
    fi
}

print_system_info() {
    detect_system
    print_os
    print_primary_pm
    print_secondary_pm
    print_optionals
    print_init_system
    print_bootloader
    print_filesystems
    print_swap_partition
    print_swapfile
    print_desktop
    print_display
    print_gpu
    print_network_interface
    print_battery
    print_optical_drive
}

announce_upgrade() {
    local manager="$1"
    green_message "$manager:" "upgrading packages"
}

announce_clean() {
    local manager="$1"
    green_message "$manager:" "cleaning packages"
}

announce_list() {
    local manager="$1"
    green_message "$manager:" "listing packages"
}

announce_list_locked() {
    local manager="$1"
    green_message "$manager:" "listing locked packages"
}

announce_search() {
    local manager="$1"
    local package="$2"
    green_message "$manager:" "searching for '$package'"
}

announce_install() {
    local manager="$1"
    local package="$2"
    green_message "$manager:" "installing '$package'"
}

announce_remove() {
    local manager="$1"
    local package="$2"
    green_message "$manager:" "removing '$package'"
}

announce_lock() {
    local manager="$1"
    local package="$2"
    green_message "$manager:" "locking '$package'"
}

announce_unlock() {
    local manager="$1"
    local package="$2"
    green_message "$manager:" "unlocking '$package'"
}

announce_bootloader_update() {
    local bootloader="$1"
    green_message "$bootloader:" "updating"
}

unsupported_operating_system() { red_message "Error:" "Unsupported operating system."; }

unsupported_package_manager() { red_message "Error:" "Unsupported package manager."; }

unsupported_desktop() { red_message "Error:" "Unsupported desktop."; }

unsupported_session_type() { red_message "Error:" "Unsupported session type."; }

unsupported_init_system() { red_message "Error:" "Unsupported init system."; }

unsupported_bootloader() { red_message "Error:" "Unsupported bootloader."; }

reboot_required() {
    local packages=("$@")
    for package in "${packages[@]}"; do
        yellow_message "Reboot required:" "Reboot to use '$package'."
    done
}

manual_install_required() {
    local package="$1"
    yellow_message "Manual installation required:" "$package"
}

no_function_available() {
    local manager="$1"
    yellow_message "$manager:" "no function available"
}

no_package_available() {
    local manager="$1"
    local package="$2"
    yellow_message "$manager:" "Package '$package' not available."
}

no_package_found() {
    local manager="$1"
    local package="$2"
    yellow_message "$manager:" "no matches found for '$package'" >&2
}

info_trailing_slash_mismatch() { blue_message "Info:" "/path/to/directory != /path/to/directory/"; }
