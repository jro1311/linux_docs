enable_strict_mode() { set -euo pipefail; }

disable_strict_mode() { set +euo pipefail; }

enable_debug_mode() { set -vx; }

disable_debug_mode() { set +vx; }

unsupported_package_manager() { echo "${red}Unsupported package manager. ${reset}"; }

unsupported_operating_system() { echo "${red}Unsupported operating system. ${reset}"; }

unsupported_init_system() { echo "${red}Unsupported init system. ${reset}"; }

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
