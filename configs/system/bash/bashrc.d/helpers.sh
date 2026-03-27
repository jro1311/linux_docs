red_message() {
    local message="$1"
    echo "${red}$message ${reset}"
}

green_message() {
    local message="$1"
    echo "${green}$message ${reset}"
}

yellow_message() {
    local message="$1"
    echo "${yellow}$message ${reset}"
}

blue_message() {
    local message="$1"
    echo "${blue}$message ${reset}"
}

check() {
    local cmd="$1"
    shift
    if command -v "$cmd" >/dev/null 2>&1; then
        "$@"
    fi
}

inverse_check() {
    local cmd="$1"
    shift
    if ! command -v "$cmd" >/dev/null 2>&1; then
        "$@"
    fi
}

check_flatpak() {
    local pkg="$1"
    shift
    if flatpak info "$pkg"  >/dev/null 2>&1; then
        "$@"
    fi
}

inverse_check_flatpak() {
    local pkg="$1"
    shift
    if ! flatpak info "$pkg"  >/dev/null 2>&1; then
        "$@"
    fi
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

sudo_run() {
    if [ "$#" -lt 1 ]; then
        red_message "One or more argument(s) missing."
        return 1
    fi

    if "$@" >/dev/null 2>&1; then
        return 0
    elif sudo "$@" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

sudo_run_passthrough() {
    if [ "$#" -lt 1 ]; then
        red_message "One or more argument(s) missing."
        return 1
    fi

    if "$@"; then
        return 0
    elif sudo "$@"; then
        return 0
    else
        return 1
    fi
}

enable_strict_mode() { set -euo pipefail; }
disable_strict_mode() { set +euo pipefail; }

enable_debug_mode() { set -vx; }
disable_debug_mode() { set +vx; }

enable_cow() { sudo_run chattr -C; }
enable_cow_recursive() { sudo_run chattr -R -C; }
disable_cow() { sudo_run chattr +C; }
disable_cow_recursive() { sudo_run chattr -R +C; }

unsupported_operating_system() { echo "${red}Unsupported operating system. ${reset}"; }
unsupported_package_manager() { echo "${red}Unsupported package manager. ${reset}"; }
unsupported_desktop() { echo "${red}Unsupported desktop. ${reset}"; }
unsupported_init_system() { echo "${red}Unsupported init system. ${reset}"; }
unsupported_bootloader() { echo "${red}Unsupported bootloader. ${reset}"; }
reboot_required() { echo "${yellow}Reboot and run script again to complete. ${reset}"; }

no_package_found() {
    local manager="$1"
    local package="$2"
    echo "${yellow}${manager}: '$package' not found${reset}" >&2
}

install_packages() {
    local packages=("$@")
    if [ ${#packages[@]} -eq 0 ]; then
        return 0
    fi

    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y "${packages[@]}"
            ;;
        "dnf")
            sudo dnf install -y "${packages[@]}"
            ;;
        "eopkg")
            sudo eopkg install -y "${packages[@]}"
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm "${packages[@]}"
            ;;
        "xbps")
            sudo xbps-install -Sy "${packages[@]}"
            ;;
        "zypper")
            sudo zypper in -y "${packages[@]}"
            ;;
        "rpm-ostree")
            inverse_check "${packages[@]}" \
                sudo rpm-ostree install "${packages[@]}"
            ;;
        *)
            unsupported_package_manager
            return 1
            ;;
    esac
}

remove_packages() {
    local packages=("$@")
    if [ ${#packages[@]} -eq 0 ]; then
        return 0
    fi

    case "$primary_package_manager" in
        "apt")
            sudo apt-get remove -y "${packages[@]}"
            ;;
        "dnf")
            sudo dnf remove -y "${packages[@]}"
            ;;
        "eopkg")
            sudo eopkg remove -y "${packages[@]}"
            ;;
        "pacman")
            sudo pacman -Rs --noconfirm "${packages[@]}"
            ;;
        "xbps")
            sudo xbps-remove -Ry "${packages[@]}"
            ;;
        "zypper")
            sudo zypper rm --clean-deps -y "${packages[@]}"
            ;;
        "rpm-ostree")
            check "${packages[@]}" \
                sudo rpm-ostree remove "${packages[@]}"
            ;;
        *)
            unsupported_package_manager
            return 1
            ;;
    esac
}

append_text() {
    if [ "$#" -ne 2 ]; then
        red_message "One or more argument(s) missing."
        return 1
    fi

    local input_text="$1"
    local filename="$2"

    if sudo_run_passthrough sh -c 'echo "$1" | tee -a "$2"' sh "$input_text" "$filename" >/dev/null 2>&1; then
        green_message "'$input_text' appended to '$filename'."
    else
        red_message "Failed to append text to '$filename'."
        return 1
    fi
}

prepend_text() {
    if [ "$#" -ne 2 ]; then
        red_message "One or more argument(s) missing."
        return 1
    fi

    local input_text="$1"
    local filename="$2"
    local temp_file
    temp_file=$(mktemp) || return 1

    if ! sudo_run_passthrough sh -c \
        "{ printf '%s\n' \"$input_text\"; cat \"$filename\"; }" >"$temp_file"; then
        red_message "Failed to create temporary file for '$filename'."
        rm -f "$temp_file"
        return 1
    fi

    if sudo_run command install -m "$(stat -c %a "$filename")" \
            --owner="$(stat -c %U "$filename")" \
            --group="$(stat -c %G "$filename")" \
            "$temp_file" "$filename"; then
        rm -f "$temp_file"
        green_message "'$input_text' prepended to '$filename'."
    else
        red_message "Failed to prepend text to '$filename'."
        rm -f "$temp_file"
        return 1
    fi
}

remove_text() {
    if [ "$#" -ne 2 ]; then
        red_message "One or more argument(s) missing."
        return 1
    fi

    local input_text="$1"
    local filename="$2"

    if sudo_run_passthrough sed -i "s/${input_text}//g" "$filename" 2>/dev/null; then
        green_message "'$input_text' removed from '$filename'."
    else
        red_message "Failed to remove text from '$filename'."
        return 1
    fi
}

trim_trailing_blanks() {
    if [ "$#" -ne 1 ]; then
        red_message "One argument required: <filename>"
        return 1
    fi

    local filename="$1"

    if sudo_run sed -i ':a;/^[[:space:]]*$/{$d;N;ba}' "$filename"; then
        green_message "Trimmed trailing blanks from '$filename'."
    else
        red_message "Failed to trim trailing blanks from '$filename'."
        return 1
    fi
}

add_kernel_parameter() {
    if [ "$#" -eq 0 ]; then
        red_message "No argument(s) provided."
        return 1
    fi

    local karg="$1"
    case "$primary_package_manager" in
        "rpm-ostree")
            if ! rpm-ostree kargs | grep -Fq "$karg"; then
                sudo rpm-ostree kargs --append="$karg"
                green_message "'$karg' added to kernel parameters."
            else
                green_message "'$karg' already part of kernel parameters."
            fi
            ;;
        *)
            case "$bootloader" in
                "grub")
                    if ! grep -Fq "$karg" /etc/default/grub; then
                        sudo sed -i "s/\(GRUB_CMDLINE_LINUX=\"[^\"]*\)\"/\1 $karg\"/" /etc/default/grub
                        sudo bash -c "$update_bootloader"
                        green_message "'$karg' added to kernel parameters."
                    else
                        green_message "'$karg' already part of kernel parameters."
                    fi
                    ;;
                "limine")
                    if ! grep -Fq "$karg" /etc/default/limine; then
                        sudo sed -i "/^KERNEL_CMDLINE\[default\\]/ s/\"$/ $karg\"/" /etc/default/limine
                        sudo bash -c "$update_bootloader"
                        green_message "'$karg' added to kernel parameters."
                    else
                        green_message "'$karg' already part of kernel parameters."
                    fi
                    ;;
                *)
                    unsupported_bootloader
                    return 1
            esac
            ;;
    esac
}

remove_kernel_parameter() {
    if [ "$#" -eq 0 ]; then
        red_message "No argument(s) provided."
        return 1
    fi

    local karg="$1"
    case "$primary_package_manager" in
        "rpm-ostree")
            if rpm-ostree kargs | grep -Fq "$karg"; then
                sudo rpm-ostree kargs --delete="$karg"
                green_message "'$karg' removed from kernel parameters."
            else
                yellow_message "'$karg' not part of kernel parameters."
            fi
            ;;
        *)
            case "$bootloader" in
                "grub")
                    if grep -Fq "$karg" /etc/default/grub; then
                        sudo sed -i -e "s/$karg//g" -e 's/ *"$/"/' /etc/default/grub
                        sudo bash -c "$update_bootloader"
                        green_message "'$karg' removed from kernel parameters."
                    else
                        yellow_message "'$karg' not part of kernel parameters."
                    fi
                    ;;
                "limine")
                    if grep -Fq "$karg" /etc/default/limine; then
                        sudo sed -i -e "s/$karg//g" -e 's/ *"$/"/' /etc/default/limine
                        sudo bash -c "$update_bootloader"
                        green_message "'$karg' removed from kernel parameters."
                    else
                        yellow_message "'$karg' not part of kernel parameters."
                    fi
                    ;;
                *)
                    unsupported_bootloader
                    return 1
            esac
            ;;
    esac
}

install_paru() {
    if [ "$primary_package_manager" = "pacman" ]; then
        sudo pacman -S --needed --noconfirm base-devel git
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si --noconfirm
        cd ..
        rm -rf paru
        secondary_package_manager="paru"
    else
        unsupported_package_manager
        return 1
    fi
}

install_yay() {
    if [ "$primary_package_manager" = "pacman" ]; then
        sudo pacman -S --needed --noconfirm base-devel git
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
        secondary_package_manager="yay"
    else
        unsupported_package_manager
        return 1
    fi
}

enable_chaotic_aur() {
    if [ "$primary_package_manager" = "pacman" ]; then
        if ! grep -Fq "chaotic" /etc/pacman.conf; then
            sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
            sudo pacman-key --lsign-key 3056513887B78AEB
            sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
            sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
            sudo tee -a /etc/pacman.conf <<-'EOF'
            [chaotic-aur]
                Include = /etc/pacman.d/chaotic-mirrorlist

EOF
            green_message "Enabled: Chaotic AUR"
        fi
    else
        unsupported_package_manager
        return 1
    fi
}

enable_debian_contrib() {
    case "$os" in
        "debian")
            # Converts old sources.list format into modern debian.sources format
            sudo apt modernize-sources -y

            if ! grep -Fq "contrib" /etc/apt/sources.list.d/debian.sources; then
                sudo sed -i '/Components:/ s/$/ contrib/' /etc/apt/sources.list.d/debian.sources
                sudo apt-get update
            fi
            ;;
        "ubuntu")
            unsupported_operating_system
            return 1
            ;;
        *)
            case "$os_like" in
                "debian")
                    sudo apt modernize-sources -y

                    if ! grep -Fq "contrib" /etc/apt/sources.list.d/debian.sources; then
                        sudo sed -i '/Components:/ s/$/ contrib/' /etc/apt/sources.list.d/debian.sources
                        sudo apt-get update
                    fi
                    ;;
                *)
                    unsupported_operating_system
                    return 1
            esac
        ;;
    esac

    green_message "Enabled: Debian contrib repository"
}

enable_debian_backports() {
    case "$os" in
        "debian")
            # Converts old sources.list format into modern debian.sources format
            sudo apt modernize-sources -y

            if ! [ -f /etc/apt/sources.list.d/debian_backports.sources ]; then
                sudo cp -v "$HOME/Documents/linux_docs/configs/system/debian_backports.sources" /etc/apt/sources.list.d/
                sudo sed -i "/Suites:/ s/version-backports/$(lsb_release -cs)-backports/" /etc/apt/sources.list.d/debian_backports.sources
                sudo apt-get update
            fi
            ;;
        "ubuntu")
            unsupported_operating_system
            return 1
            ;;
        *)
            case "$os_like" in
                "debian")
                    sudo apt modernize-sources -y

                    if [ ! -f /etc/apt/sources.list.d/debian_backports.sources ]; then
                        sudo cp -v "$HOME/Documents/linux_docs/configs/system/debian_backports.sources" /etc/apt/sources.list.d/
                        sudo sed -i "/Suites:/ s/version-backports/$(lsb_release -cs)-backports/" /etc/apt/sources.list.d/debian_backports.sources
                        sudo apt-get update
                    fi
                    ;;
                *)
                    unsupported_operating_system
                    return 1
            esac
        ;;
    esac

    green_message "Enabled: Debian backports repository"
}

enable_permanent_mac_address() {
    if command -v nmcli >/dev/null 2>&1; then
        green_message "Detected: Network Manager"

        if [ ! -f /etc/NetworkManager/conf.d/10-permanent-mac-address.conf ]; then
            sudo mkdir -pv /etc/NetworkManager/conf.d
            sudo cp -v "$HOME/Documents/linux_docs/configs/system/network_manager/10-permanent-mac-address.conf" /etc/NetworkManager/conf.d/

            if command -v systemctl >/dev/null 2>&1; then
                sudo systemctl restart NetworkManager
            fi
        else
            green_message "Permanent MAC address already enabled."
            return 0
        fi
    else
        yellow_message "Network Manager not detected."
    fi

    green_message "Enabled: Permanent MAC address"
}

enable_xorg_vrr() {
    case "$XDG_SESSION_TYPE" in
        "x11")
            green_message "Session: X11"
            if echo "$gpu_info" | grep -Fiq "amd"; then
                green_message "Detected GPU: AMD"
                sudo cp -v "$HOME/Documents/linux_docs/configs/system/xorg/10-amdgpu.conf" /etc/X11/xorg.conf.d/
            else
                yellow_message "No AMD GPU detected."
                echo "Nothing to do."
                return 0
            fi
            ;;
        "wayland")
            green_message "Session: Wayland"
            echo "Nothing to do."
            return 0
            ;;
        *)
            red_message "Unknown session."
            return 1
            ;;
    esac

    green_message "Enabled: Variable Refresh Rate. Setting will be enabled after reboot or relogin."
}

enable_zswap() {
    compressor="unknown"
    if [ "$host_system" = "laptop" ]; then
        compressor="lz4"
    else
        compressor="zstd"
    fi

    echo 1 | sudo tee /sys/module/zswap/parameters/enabled >/dev/null 2>&1
    echo Y | sudo tee /sys/module/zswap/parameters/shrinker_enabled >/dev/null 2>&1
    echo 25 | sudo tee /sys/module/zswap/parameters/max_pool_percent >/dev/null 2>&1
    echo "$compressor" | sudo tee /sys/module/zswap/parameters/compressor >/dev/null 2>&1
    if [ -f /sys/module/zswap/parameters/zpool ]; then
        echo zsmalloc | sudo tee /sys/module/zswap/parameters/zpool >/dev/null 2>&1
    fi
    echo 90 | sudo tee /sys/module/zswap/parameters/accept_threshold_percent >/dev/null 2>&1

    remove_kernel_parameter "zswap.enabled=0"
    add_kernel_parameter "zswap.enabled=1 zswap.shrinker_enabled=1 zswap.max_pool_percent=25 zswap.compressor=$compressor zswap.zpool=zsmalloc zswap.accept_threshold_percent=90"

    if [ -f /etc/sysctl.d/99-zram.conf ]; then
        sudo rm -v /etc/sysctl.d/99-zram.conf
    fi

    if [ ! -f /etc/sysctl.d/99-swap.conf ]; then
        sudo cp -v "$HOME/Documents/linux_docs/configs/system/99-swap.conf" /etc/sysctl.d/
        sudo sed -i 's/vm.swappiness \=\ 30/vm.swappiness \=\ 60/' /etc/sysctl.d/99-swap.conf
        sudo sysctl -p /etc/sysctl.d/99-swap.conf
    fi

    green_message "Enabled: zswap"
}

disable_zswap() {
    compressor="unknown"
    if [ "$host_system" = "laptop" ]; then
        compressor="lz4"
    else
        compressor="zstd"
    fi

    echo 0 | sudo tee /sys/module/zswap/parameters/enabled >/dev/null 2>&1

    remove_kernel_parameter "zswap.enabled=1 zswap.shrinker_enabled=1 zswap.max_pool_percent=25 zswap.compressor=$compressor zswap.zpool=zsmalloc zswap.accept_threshold_percent=90"
    add_kernel_parameter "zswap.enabled=0"

    green_message "Disabled: zswap"
}

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
