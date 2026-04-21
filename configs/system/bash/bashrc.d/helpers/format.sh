# shellcheck shell=bash
# shellcheck source=/dev/null
# shellcheck disable=SC2034,SC2154

red_message() {
    local label="$1"
    local value="${2:-}"
    echo "${red}$label${reset} $value"
}

green_message() {
    local label="$1"
    local value="${2:-}"
    echo "${green}$label${reset} $value"
}

yellow_message() {
    local label="$1"
    local value="${2:-}"
    echo "${yellow}$label${reset} $value"
}

blue_message() {
    local label="$1"
    local value="${2:-}"
    echo "${blue}$label${reset} $value"
}

announce_upgrade() {
    local manager="$1"
    echo "${green}$manager:${reset} upgrading packages"
}

announce_clean() {
    local manager="$1"
    echo "${green}$manager:${reset} cleaning packages"
}

announce_list() {
    local manager="$1"
    echo "${green}$manager:${reset} listing packages"
}

announce_list_locked() {
    local manager="$1"
    echo "${green}$manager:${reset} listing locked packages"
}

announce_search() {
    local manager="$1"
    local package="$2"
    echo "${green}$manager:${reset} searching for '$package'"
}

announce_install() {
    local manager="$1"
    local package="$2"
    echo "${green}$manager:${reset} installing '$package'"
}

announce_remove() {
    local manager="$1"
    local package="$2"
    echo "${green}$manager:${reset} removing '$package'"
}

announce_lock() {
    local manager="$1"
    local package="$2"
    echo "${green}$manager:${reset} locking '$package'"
}

announce_unlock() {
    local manager="$1"
    local package="$2"
    echo "${green}$manager:${reset} unlocking '$package'"
}

unsupported_operating_system() { red_message "Unsupported operating system."; }

unsupported_package_manager() { red_message "Unsupported package manager."; }

unsupported_desktop() { red_message "Unsupported desktop."; }

unsupported_init_system() { red_message "Unsupported init system."; }

unsupported_bootloader() { red_message "Unsupported bootloader."; }

reboot_required() {
    local packages=("$@")
    for package in "${packages[@]}"; do
        yellow_message "Reboot required:" "Reboot to use '$package'."
    done
}

no_function_available() {
    local manager="$1"
    echo "${yellow}$manager:${reset} no function available"
}

no_package_found() {
    local manager="$1"
    local package="$2"
    yellow_message "$manager:" "no matches found for '$package'" >&2
}

print_field() {
    if [ "$#" -ne 2 ]; then
        red_message "print_field:" "Expected 2 arguments, got $#."
        return 1
    fi

    detect_system
    local label="$1"
    local var="$2"
    if [ -z "$var" ]; then
        return 0
    fi

    green_message "$label:" "$var"
}

ask_for_confirmation() {
    local prompt="$1"
    local answer

    while true; do
        read -r -p "$prompt [Y/n]: " answer
        answer="${answer:-y}"

        case "$answer" in
            [Yy]) return 0 ;;
            [Nn]) return 1 ;;
            *) echo "Enter a 'y' or 'n'." ;;
        esac
    done
}

confirm() {
    while true; do
        read -r -p "Confirm? [Y/n]: " answer
        answer="${answer:-y}"

        case "$answer" in
            [Yy])
                "$@"
                break
                ;;
            [Nn])
                break
                ;;
            *)
                echo "Enter a 'y' or 'n'."
                ;;
        esac
    done
}

confirm_proceed() { read -r -p "Press ${green}ENTER${reset} to proceed or ${red}CTRL+C${reset} to cancel: "; }

format_bytes() {
    bytes=$1

    if [ "$bytes" -ge $((1024*1024*1024)) ]; then
        value=$(awk "BEGIN { printf \"%.1f\", $bytes / (1024*1024*1024) }")
        units="GiB"

    elif [ "$bytes" -ge $((1024*1024)) ]; then
        value=$(awk "BEGIN { printf \"%.1f\", $bytes / (1024*1024) }")
        units="MiB"

    else
        value=$(awk "BEGIN { printf \"%.1f\", $bytes / 1024 }")
        units="KiB"
    fi

    printf "%s %s" "$value" "$units"
}
