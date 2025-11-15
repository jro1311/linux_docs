enable_strict_mode() { set -euo pipefail; }

disable_strict_mode() { set +euo pipefail; }

enable_debug_mode() { set -vx; }

disable_debug_mode() { set +vx; }

unsupported_package_manager() { echo "${red}Unsupported package manager. ${reset}"; }

unsupported_operating_system() { echo "${red}Unsupported operating system. ${reset}"; }

unsupported_init_system() { echo "${red}Unsupported init system. ${reset}"; }

unsupported_bootloader() { echo "${red}Unsupported bootloader. ${reset}"; }

reboot_required() { echo "${yellow}Reboot and run script again to complete. ${reset}"; }

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

blue_message() {
    local message="$1"
    echo "${blue}$message ${reset}"
}

green_message() {
    local message="$1"
    echo "${green}$message ${reset}"
}

red_message() {
    local message="$1"
    echo "${red}$message ${reset}"
}

yellow_message() {
    local message="$1"
    echo "${yellow}$message ${reset}"
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
                echo "Enter y or n."
                ;;
        esac
    done
}

install_packages() {
    local packages=("$@")
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

no_package_found() {
    local manager="$1"
    local package="$2"
    echo "${yellow}${manager}: '$package' not found${reset}" >&2
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
                echo "${green}Enabled: Debian contrib repository ${reset}"
            fi
            ;;
        "ubuntu")
            echo "${red}Unsupported operating system. ${reset}"
            return 1
            ;;
        *)
            case "$os_like" in
                "debian")
                    sudo apt modernize-sources -y

                    if ! grep -Fq "contrib" /etc/apt/sources.list.d/debian.sources; then
                        sudo sed -i '/Components:/ s/$/ contrib/' /etc/apt/sources.list.d/debian.sources
                        sudo apt-get update
                        echo "${green}Enabled: Debian contrib repository ${reset}"
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
            sudo cp -v "$HOME/Documents/linux_docs/configs/packages/network_manager/10-permanent-mac-address.conf" /etc/NetworkManager/conf.d/

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
    # Enables zswap on runtime
    echo 1 | sudo tee /sys/module/zswap/parameters/enabled

    local zswap_karg="zswap.enabled=1"

    case "$primary_package_manager" in
        "rpm-ostree")
            if ! rpm-ostree kargs | grep -Fq "$zswap_karg"; then
                sudo rpm-ostree kargs --append="$zswap_karg"
                echo "${green}'Added $zswap_karg' to kernel arguments. ${reset}"
            else
                echo "${green}'$zswap_karg' is already part of kernel arguments. ${reset}"
            fi
            ;;
        *)
            case "$bootloader" in
                "grub")
                    if ! grep -Fq "$zswap_karg" /etc/default/grub; then
                        sudo sed -i "s/\(GRUB_CMDLINE_LINUX=\"[^\"]*\)\"/\1 $zswap_karg\"/" /etc/default/grub
                        echo "${green}Added '$zswap_karg' to kernel arguments. ${reset}"
                    else
                        echo "${green}'$zswap_karg' is already part of kernel arguments. ${reset}"
                    fi
                    ;;
                "limine")
                    if ! grep -Fq "$zswap_karg" /etc/default/limine; then
                        sudo sed -i "/^KERNEL_CMDLINE\[default\\]/ s/\"$/ $zswap_karg\"/" /etc/default/limine
                        echo "${green}Added '$zswap_karg' to kernel arguments. ${reset}"
                    else
                        echo "${green}'$zswap_karg' is already part of kernel arguments. ${reset}"
                    fi
                    ;;
                *)
                    unsupported_bootloader
                    return 1
            esac
            ;;
    esac

    if [ "$bootloader" = "grub" ]; then
        sudo bash -c "$update_bootloader"

    elif [ "$bootloader" = "limine" ]; then
        sudo bash -c "$update_bootloader"
    fi

    green_message "Enabled: zswap"
}
