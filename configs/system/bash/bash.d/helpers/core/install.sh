# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

install_pm_pkg_bypass() {
    [ "$#" -eq 0 ] && return 0

    detect_system
    green_message "$primary_pm:" "installing $# pkgs..."

    case "$primary_pm" in
        apt)        sudo apt-get install -y "$@"                >/dev/null || : ;;
        dnf)        sudo dnf install -y "$@"                    >/dev/null || : ;;
        eopkg)      sudo eopkg install -y "$@"                  >/dev/null || : ;;
        pacman)     sudo pacman -S --needed --noconfirm "$@"    >/dev/null || : ;;
        xbps)       sudo xbps-install -Sy "$@"                  >/dev/null || : ;;
        zypper)     sudo zypper in -y "$@"                      >/dev/null || : ;;
        rpm-ostree) sudo rpm-ostree install --idempotent "$@"   >/dev/null || : ;;
    esac
}

install_aur_pkg_bypass() {
    [ "$#" -eq 0 ] && return 0

    detect_system

    [ "$primary_pm" != "pacman" ] && return 0

    case "$secondary_pm" in
        paru|yay) ;;
        *)
            install_yay || return 1
            secondary_pm="yay"
            ;;
    esac

    green_message "$secondary_pm:" "installing $# AUR pkgs..."
    "$secondary_pm" -S --needed --noconfirm "$@" >/dev/null || :
}

install_flatpak_pkg_bypass() {
    [ "$#" -eq 0 ] && return 0

    detect_system

    [ "$flatpak_installed" -eq 0 ] && return 0

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    green_message "flatpak:" "installing $# flatpaks..."
    flatpak install flathub -y "$@" 2>/dev/null || :
}

ensure_pkg() {
    [ "$#" -eq 0 ] && return 0

    detect_system

    local pkg norm_pkg
    local missing=()

    for pkg in "$@"; do
        norm_pkg=$(normalize_pkg "$pkg") || return 1

        if ! pkg_installed_pm "$norm_pkg"; then
            missing+=("$norm_pkg")
        fi
    done

    [ ${#missing[@]} -eq 0 ] && return 0

    case "$primary_pm" in
        rpm-ostree)
            install_pm_pkg_bypass "${missing[@]}" || return 1
            reboot_required "$primary_pm" "${missing[*]}"
            return 1
            ;;
        *)
            install_pm_pkg_bypass "${missing[@]}" || return 1
            return 0
            ;;
    esac
}

install_primary_packages() {
    detect_system

    case "$primary_pm" in
        rpm-ostree) ensure_pkg "${atomic_pkgs[@]}" ;;
        *)          ensure_pkg "${resolved_pkgs[@]}" ;;
    esac

    if [ -n "$secondary_pm" ] && [ "$primary_pm" = "pacman" ]; then
        install_aur_pkg_bypass "${aur_pkgs[@]}"
    fi

    ensure_pkg "rocm-smi"

    case "$primary_pm" in
        "rpm-ostree") ;;
        *)
            ensure_pkg "micro"
            ensure_pkg "cpu-x"
            ;;
    esac

    if ! ensure_pkg "fastfetch" 2>/dev/null; then
        ensure_pkg "neofetch"
    fi

    if [ "$swapfile_exists" -eq 0 ] && [ "$swap_partition_exists" -eq 0 ]; then
        install_zram
    fi
}

_install_brave_native_override() {
    case "$primary_pm" in
        xbps) return 1 ;;
    esac

    if ! pkg_installed_pm "brave-browser"; then
        curl -fsS https://dl.brave.com/install.sh | sh
    fi

    return 0
}

install_selection() {
    local selected="$1"
    local -n category="$2"
    local -n native_array="${category[native]}"
    local -n flatpak_array="${category[flatpak]}"
    local native_pkg="${native_array[$selected]}"
    local flatpak="${flatpak_array[$selected]}"
    local override="${chromium_native_overrides[$selected]-}"

    # Install only flatpak
    if [ -n "$flatpak" ] &&
        { [ "${category[force_flatpak]:-0}" = 1 ] || [ "$primary_pm" = "rpm-ostree" ]; } &&
        ! pkg_installed_pm "$native_pkg"; then

        install_flatpak_pkg_bypass "$flatpak"
        return 0
    fi

    # Install native pkg unless flatpak is preferred
    if [ -n "$native_pkg" ]; then
        if pkg_installed_pm "$native_pkg"; then
            return 0
        fi

        if [ "$override" != "false" ] && [ -n "$flatpak" ]; then
            install_flatpak_pkg_bypass "$flatpak"
            return 0
        fi

        install_pm_pkg_bypass "$native_pkg"
        return 0
    fi

    # Fallback to flatpak
    if [ -n "$flatpak" ]; then
        install_flatpak_pkg_bypass "$flatpak"
        return 0
    fi

    return 1
}
