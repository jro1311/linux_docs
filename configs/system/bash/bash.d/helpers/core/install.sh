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
        rpm-ostree)
            ensure_pkg "${atomic_pkgs[@]}"
            ;;
        *)
            resolve_packages
            ensure_pkg "${resolved_pkgs[@]}"
            ;;
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
        xbps|rpm-ostree) return 1 ;;
    esac

    if ! pkg_installed_pm "brave-browser"; then
        curl -fsS https://dl.brave.com/install.sh | sh
    fi

    return 0
}

_install_transmission_native_override() {
    case "$primary_pm" in
        rpm-ostree) return 1 ;;
    esac

    if pkg_installed_pm "transmission" \
        || pkg_installed_pm "transmission-gtk" \
        || pkg_installed_pm "transmission-qt"; then
        return 0
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
    local override="${native_overrides[$selected]-}"

    # Install flatpak on rpm-ostree
    if [ "$primary_pm" = "rpm-ostree" ] \
        && [ -n "$flatpak" ] \
        && ! pkg_installed_flatpak "$flatpak"; then

        install_flatpak_pkg_bypass "$flatpak" || return 1
        return 0
    fi

    if [ "$selected" = "transmission" ]; then
        if is_qt_preferred_env "$desktop"; then
            native_pkg="${transmission_qt_pkg[$primary_pm]}"
        else
            native_pkg="${transmission_gtk_pkg[$primary_pm]}"
        fi
    fi

    if [ -n "$native_pkg" ] \
        && pkg_installed_pm "$native_pkg"; then
        return 0
    fi

    # Block native if override
    if [ -n "$override" ]; then
        if ! "$override"; then
            if [ -n "$flatpak" ] \
                && ! pkg_installed_flatpak "$flatpak"; then
                install_flatpak_pkg_bypass "$flatpak" || return 1
            fi

            return 0
        fi
    fi

    # Prefer native
    if [ "${category[force_flatpak]:-0}" = 0 ] \
        && [ -n "$native_pkg" ]; then

        install_pm_pkg_bypass "$native_pkg" || return 1
        return 0
    fi

    # Prefer flatpak
    if [ "${category[force_flatpak]:-0}" = 1 ] \
        && [ -n "$flatpak" ] \
        && ! pkg_installed_flatpak "$flatpak"; then

        install_flatpak_pkg_bypass "$flatpak" || return 1
        return 0
    fi

    # Fallback to flatpak
    if [ -n "$flatpak" ] \
        && ! pkg_installed_flatpak "$flatpak"; then

        install_flatpak_pkg_bypass "$flatpak" || return 1
        return 0
    fi

    return 1
}
