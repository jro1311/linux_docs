# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_install_nala_pkg() {
    local mode="$1"
    local pkg="$2"

    if dpkg -s "$pkg" >/dev/null 2>&1; then
        already_installed "$secondary_pm" "$pkg"
        return 0
    fi

    if apt-cache policy "$pkg" | grep -Fq "Candidate:"; then
        announce_install "$secondary_pm" "$pkg"

        case "$mode" in
            auto)
                sudo nala install -y "$pkg"
                ;;
            manual|*)
                sudo nala install "$pkg"
                ;;
        esac
    else
        no_pkg_found "$secondary_pm" "$pkg"
        return 1
    fi
}

_install_apt_pkg() {
    local mode="$1"
    local pkg="$2"

    if dpkg -s "$pkg" >/dev/null 2>&1; then
        already_installed "$primary_pm" "$pkg"
        return 0
    fi

    if apt-cache policy "$pkg" | grep -Fq "Candidate:"; then
        announce_install "$primary_pm" "$pkg"

        case "$mode" in
            auto)
                sudo apt-get install -y "$pkg"
                ;;
            manual|*)
                sudo apt install "$pkg"
                ;;
        esac
    else
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi
}

_install_dnf_pkg() {
    local mode="$1"
    local pkg="$2"

    if rpm -q "$pkg" >/dev/null 2>&1; then
        already_installed "$primary_pm" "$pkg"
        return 0
    fi

    if dnf repoquery --quiet --qf '%{name}' "$pkg" | grep -Fxq "$pkg"; then
        announce_install "$primary_pm" "$pkg"

        case "$mode" in
            auto)
                sudo dnf install -y "$pkg"
                ;;
            manual|*)
                sudo dnf install "$pkg"
                ;;
        esac
    else
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi
}

_install_eopkg_pkg() {
    local mode="$1"
    local pkg="$2"

    if eopkg search -i --name "^$pkg$" 2>/dev/null \
        | awk -F' - ' '{print $1}' \
        | grep -Fq "$pkg"; then

        already_installed "$primary_pm" "$pkg"
        return 0
    fi

    if eopkg search --name "^$pkg$" 2>/dev/null \
        | awk -F' - ' '{print $1}' \
        | grep -Fq "$pkg"; then

        announce_install "$primary_pm" "$pkg"

        case "$mode" in
            auto)
                sudo eopkg install -y "$pkg"
                ;;
            manual|*)
                sudo eopkg install "$pkg"
                ;;
        esac
    else
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi
}

_install_aur_pkg() {
    local mode="$1"
    local pkg="$2"

    if "$secondary_pm" -Qq "$pkg" >/dev/null 2>&1; then
        already_installed "$secondary_pm" "$pkg"
        return 0
    fi

    if "$secondary_pm" -Si "$pkg" >/dev/null 2>&1; then
        announce_install "$secondary_pm" "$pkg"

        case "$mode" in
            auto)
                "$secondary_pm" -S --needed --noconfirm "$pkg"
                ;;
            manual|*)
                "$secondary_pm" -S --needed "$pkg"
                ;;
        esac
    else
        no_pkg_found "$secondary_pm" "$pkg"
        return 1
    fi
}

_install_pacman_pkg() {
    local mode="$1"
    local pkg="$2"

    if "$primary_pm" -Qq "$pkg" >/dev/null 2>&1; then
        already_installed "$primary_pm" "$pkg"
        return 0
    fi

    if pacman -Si "$pkg" >/dev/null 2>&1; then
        announce_install "$primary_pm" "$pkg"

        case "$mode" in
            auto)
                sudo pacman -S --needed --noconfirm "$pkg"
                ;;
            manual|*)
                sudo pacman -S --needed "$pkg"
                ;;
        esac
    else
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi
}

_install_xbps_pkg() {
    local mode="$1"
    local pkg="$2"

    if xbps-query -p pkgver "$pkg" >/dev/null 2>&1; then
        already_installed "$primary_pm" "$pkg"
        return 0
    fi

    if xbps-query -R "$pkg" >/dev/null 2>&1; then
        announce_install "$primary_pm" "$pkg"

        case "$mode" in
            auto)
                sudo xbps-install -Sy "$pkg"
                ;;
            manual|*)
                sudo xbps-install -S "$pkg"
                ;;
        esac
    else
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi
}

_install_zypper_pkg() {
    local mode="$1"
    local pkg="$2"

    if zypper se -i --match-exact "$pkg" >/dev/null 2>&1; then
        already_installed "$primary_pm" "$pkg"
        return 0
    fi

    if zypper se --match-exact "$pkg" >/dev/null 2>&1; then
        announce_install "$primary_pm" "$pkg"

        case "$mode" in
            auto)
                sudo zypper in -y "$pkg"
                ;;
            manual|*)
                sudo zypper in "$pkg"
                ;;
        esac
    else
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi
}

_install_rpm_ostree_pkg() {
    local mode="$1"
    local pkg="$2"

    if rpm -q "$pkg" >/dev/null 2>&1; then
        already_installed "$primary_pm" "$pkg"
        return 0
    fi

    if rpm-ostree install --dry-run "$pkg" >/dev/null 2>&1; then
        announce_install "$primary_pm" "$pkg"

        case "$mode" in
            auto)
                sudo rpm-ostree install "$pkg"
                ;;
            manual|*)
                confirm "Confirm install operation [y/N]" sudo rpm-ostree install "$pkg"
                ;;
        esac
    else
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi
}

_install_toolbox_pkg() {
    local mode="$1"
    local pkg="$2"

    if toolbox run rpm -q "$pkg" >/dev/null 2>&1; then
        already_installed "toolbox" "$pkg"
        return 0
    fi

    if toolbox run dnf repoquery --quiet "$pkg" >/dev/null 2>&1; then
        announce_install "toolbox" "$pkg"

        case "$mode" in
            auto)
                toolbox run sudo dnf install -y "$pkg"
                ;;
            manual|*)
                toolbox run sudo dnf install "$pkg"
                ;;
        esac
    else
        no_pkg_found "toolbox" "$pkg"
        return 1
    fi
}

_install_flatpak_pkg() {
    local mode="$1"
    local pkg="$2"

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    if flatpak search --columns=application "$pkg" | grep -Fiq "$pkg"; then
        announce_install "flatpak" "$pkg"

        case "$mode" in
            auto)
                flatpak install flathub -y "$pkg"
                ;;
            manual|*)
                flatpak install flathub "$pkg"
                ;;
        esac
    else
        no_pkg_found "flatpak" "$pkg"
        return 1
    fi
}

_install_snap_pkg() {
    local mode="$1"
    local pkg="$2"

    if snap list "$pkg" >/dev/null 2>&1; then
        already_installed "snap" "$pkg"
        return 0
    fi

    if snap info "$pkg" >/dev/null 2>&1; then
        announce_install "snap" "$pkg"

        case "$mode" in
            auto)
                sudo snap install "$pkg"
                ;;
            manual|*)
                confirm "Confirm install operation [y/N]" sudo snap install "$pkg"
                ;;
        esac
    else
        no_pkg_found "snap" "$pkg"
        return 1
    fi
}

install_sm_pkg() {
    local mode="$1"
    local pkg="$2"

    case "$1" in
        manual|auto)
            mode="$1"
            shift
            ;;
        *)
            mode="manual"
            ;;
    esac

    pkg="$1"

    case "$secondary_pm" in
        "nala")
            _install_nala_pkg "$mode" "$pkg" && return 0
            ;;
        paru|yay)
            _install_aur_pkg "$mode" "$pkg" && return 0
            ;;
    esac
}

install_pm_pkg() {
    local mode pkg

    case "$1" in
        manual|auto)
            mode="$1"
            shift
            ;;
        *)
            mode="manual"
            ;;
    esac

    pkg="$1"

    case "$primary_pm" in
        apt)
            _install_apt_pkg "$mode" "$pkg" && return 0
            ;;
        dnf)
            _install_dnf_pkg "$mode" "$pkg" && return 0
            ;;
        eopkg)
            _install_eopkg_pkg "$mode" "$pkg" && return 0
            ;;
        pacman)
            _install_pacman_pkg "$mode" "$pkg" && return 0
            ;;
        xbps)
            _install_xbps_pkg "$mode" "$pkg" && return 0
            ;;
        zypper)
            _install_zypper_pkg "$mode" "$pkg" && return 0
            ;;
        rpm-ostree)
            _install_rpm_ostree_pkg "$mode" "$pkg" && return 0
            ;;
    esac
}

install_optionals_pkg() {
    local mode pkg
    local option
    local -a optionals=(
        toolbox
        flatpak
        snap
    )

    case "$1" in
        manual|auto)
            mode="$1"
            shift
            ;;
        *)
            mode="manual"
            ;;
    esac

    pkg="$1"

    for option in "${optionals[@]}"; do
        case "$option" in
            toolbox)
                if [ "$toolbox_installed" -eq 1 ]; then
                    _install_toolbox_pkg "$mode" "$pkg" && return 0
                fi
                ;;
            flatpak)
                if [ "$flatpak_installed" -eq 1 ]; then
                    _install_flatpak_pkg "$mode" "$pkg" && return 0
                fi
                ;;
            snap)
                if [ "$snap_installed" -eq 1 ]; then
                    _install_snap_pkg "$mode" "$pkg" && return 0
                fi
                ;;
        esac
    done

    return 1
}

install_pkg() {
    assert_arity "$#" "ge" 1 "<mode=manual> <pkg>" || return 1

    local mode="$1"

    case "$1" in
        manual|auto)
            mode="$1"
            shift
            ;;
        *)
            mode="manual"
            ;;
    esac

    detect_system

    for pkg in "$@"; do
        case "$primary_pm" in
            rpm-ostree)
                install_optionals_pkg "$mode" "$pkg" && continue
                install_pm_pkg "$mode" "$pkg"
                ;;
            *)
                if [ -n "$secondary_pm" ]; then
                    install_sm_pkg "$mode" "$pkg" && continue
                else
                    install_pm_pkg "$mode" "$pkg" && continue
                fi

                install_optionals_pkg "$mode" "$pkg"
                ;;
        esac

        case "$pkg" in
            flatpak|snap|toolbox)
                detect_optionals
                ;;
            nala)
                detect_secondary_pm
                ;;
        esac
    done
}

install_pm_pkg_bypass() {
    [ "$#" -eq 0 ] && return 0

    detect_system
    case "$primary_pm" in
        apt)        sudo apt-get install -y "$@" ;;
        dnf)        sudo dnf install -y "$@" ;;
        eopkg)      sudo eopkg install -y "$@" ;;
        pacman)     sudo pacman -S --needed --noconfirm "$@" ;;
        xbps)       sudo xbps-install -Sy "$@" ;;
        zypper)     sudo zypper in -y "$@" ;;
        rpm-ostree) sudo rpm-ostree install "$@" ;;
    esac
}

install_aur_pkg_bypass() {
    [ "$#" -eq 0 ] && return 0

    detect_system
    case "$primary_pm" in
        pacman)
            case "$secondary_pm" in
                paru|yay)
                    "$secondary_pm" -S --needed --noconfirm "$@"
                    ;;
                *)
                    install_yay || return 1
                    secondary_pm="yay"
                    "$secondary_pm" -S --needed --noconfirm "$@"
                    ;;
            esac
            ;;
    esac
}

install_flatpak_pkg_bypass() {
    [ "$#" -eq 0 ] && return 0

    detect_system
    [ "$flatpak_installed" -eq 0 ] && return 0

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub -y "$@"
}

ensure_pkg() {
    [ "$#" -eq 0 ] && return 0

    detect_system
    local spec cmd pkg

    for spec in "$@"; do
        pkg="${spec%%:*}"
        cmd="${spec#*:}"

        [ "$cmd" = "$spec" ] && cmd="$pkg"

        if ! command -v "$cmd" >/dev/null 2>&1; then
            case "$primary_pm" in
                rpm-ostree)
                    install_pm_pkg "auto" "$pkg" || return 1
                    reboot_required "$primary_pm" "$pkg"
                    return 1
                    ;;
                *)
                    install_pm_pkg "auto" "$pkg" || return 1
                    return 0
                    ;;
            esac
        fi
    done
}
