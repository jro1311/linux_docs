# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

install_nala_pkg() {
    local mode="$1"
    local package="$2"
    detect_system

    if apt list "$package" 2>/dev/null | grep -Fq "$package"; then
        case "$mode" in
            auto)
                sudo nala install -y "$package"
                ;;
            manual|*)
                sudo nala install "$package"
                ;;
        esac
    else
        no_package_found "$secondary_pm" "$package"
    fi
}

install_apt_pkg() {
    local mode="$1"
    local package="$2"
    detect_system

    if apt list "$package" 2>/dev/null | grep -Fq "$package"; then
        case "$mode" in
            auto)
                sudo apt-get install -y "$package"
                ;;
            manual|*)
                sudo apt install "$package"
                ;;
        esac
    else
        no_package_found "$primary_pm" "$package"
    fi
}

install_dnf_pkg() {
    local mode="$1"
    local package="$2"
    detect_system

    if dnf list --available "$package" >/dev/null 2>&1; then
        case "$mode" in
            auto)
                sudo dnf install -y "$package"
                ;;
            manual|*)
                sudo dnf install "$package"
                ;;
        esac
    else
        no_package_found "$primary_pm" "$package"
    fi
}

install_eopkg_pkg() {
    local mode="$1"
    local package="$2"
    detect_system

    if eopkg search --name "^$package" 2>/dev/null | grep -Fq "$package"; then
        case "$mode" in
            auto)
                sudo eopkg install -y "$package"
                ;;
            manual|*)
                sudo eopkg install "$package"
                ;;
        esac
    else
        no_package_found "$primary_pm" "$package"
    fi
}

install_aur_pkg() {
    local mode="$1"
    local package="$2"
    detect_system

    if "$secondary_pm" -Ss "^$package$" >/dev/null 2>&1; then
        case "$mode" in
            auto)
                "$secondary_pm" -S --needed --noconfirm "$package"
                ;;
            manual|*)
                "$secondary_pm" -S --needed "$package"
                ;;
        esac
    else
        no_package_found "$secondary_pm" "$package"
    fi
}

install_pacman_pkg() {
    local mode="$1"
    local package="$2"
    detect_system

    if pacman -Ss "^$package$" >/dev/null 2>&1; then
        case "$mode" in
            auto)
                sudo pacman -S --needed --noconfirm "$package"
                ;;
            manual|*)
                sudo pacman -S --needed "$package"
                ;;
        esac
    else
        no_package_found "$primary_pm" "$package"
    fi
}

install_xbps_pkg() {
    local mode="$1"
    local package="$2"
    detect_system

    if xbps-query -Rs "$package" | grep -Fq "$package"; then
        case "$mode" in
            auto)
                sudo xbps-install -Sy "$package"
                ;;
            manual|*)
                sudo xbps-install -S "$package"
                ;;
        esac
    else
        no_package_found "$primary_pm" "$package"
    fi
}

install_zypper_pkg() {
    local mode="$1"
    local package="$2"
    detect_system

    if zypper se --match-exact "$package" >/dev/null 2>&1; then
        case "$mode" in
            auto)
                sudo zypper in -y "$package"
                ;;
            manual|*)
                sudo zypper in "$package"
                ;;
        esac
    else
        no_package_found "$primary_pm" "$package"
    fi
}

install_rpm_ostree_pkg() {
    local mode="$1"
    local package="$2"
    detect_system

    if rpm-ostree search "$package" | awk 'NR > 2 {print $1}' | grep -q "^$package"; then
        ! check && {
            case "$mode" in
                auto)
                    sudo rpm-ostree install "$package"
                    ;;
                manual|*)
                    confirm sudo rpm-ostree install "$package"
                    ;;
            esac
        }
    else
        no_package_found "$primary_pm" "$package"
    fi
}

install_toolbox_pkg() {
    local mode="$1"
    local package="$2"

    if toolbox run dnf list --available "$package" >/dev/null 2>&1; then
        case "$mode" in
            auto)
                toolbox run sudo dnf install -y "$package"
                ;;
            manual|*)
                toolbox run sudo dnf install "$package"
                ;;
        esac
    else
        no_package_found "dnf (toolbox)" "$package"
        return 1
    fi
}

install_flatpak_pkg() {
    local mode="$1"
    local package="$2"

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    if flatpak search --columns=name,application "$package" | grep -Fiq "$package"; then
        case "$mode" in
            auto)
                flatpak install flathub -y "$package"
                ;;
            manual|*)
                flatpak install flathub "$package"
                ;;
        esac
    else
        no_package_found flatpak "$package"
        return 1
    fi
}

install_snap_pkg() {
    local mode="$1"
    local package="$2"

    if snap find "$package" 2>/dev/null | awk '{print $1}' | grep -Fq "$package"; then
        case "$mode" in
            auto)
                sudo snap install "$package"
                ;;
            manual|*)
                confirm sudo snap install "$package"
                ;;
        esac
    else
        no_package_found snap "$package"
        return 1
    fi
}

install_sm_pkg() {
    assert_arity "$#" "ge" 1 "<mode=manual> <package>" || return 1

    local mode
    case "$1" in
        manual|auto)
            mode="$1"
            shift
            ;;
        *)
            mode="manual"
            ;;
    esac

    local package="$1"
    detect_system

    case "$secondary_pm" in
        "nala")
            announce_remove "$secondary_pm" "$package"
            install_nala_pkg "$mode" "$package" && return 0
            ;;
        paru|yay)
            announce_remove "$secondary_pm" "$package"
            install_aur_pkg "$mode" "$package" && return 0
            ;;
    esac
}

install_pm_pkg() {
    assert_arity "$#" "ge" 1 "<mode=manual> <package>" || return 1

    local mode
    case "$1" in
        manual|auto)
            mode="$1"
            shift
            ;;
        *)
            mode="manual"
            ;;
    esac

    local package="$1"
    detect_system

    case "$primary_pm" in
        apt)
            announce_install "$primary_pm" "$package"
            install_apt_pkg "$mode" "$package" && return 0
            ;;
        dnf)
            announce_install "$primary_pm" "$package"
            install_dnf_pkg "$mode" "$package" && return 0
            ;;
        eopkg)
            announce_install "$primary_pm" "$package"
            install_eopkg_pkg "$mode" "$package" && return 0
            ;;
        pacman)
            announce_install "$primary_pm" "$package"
            install_pacman_pkg "$mode" "$package" && return 0
            ;;
        xbps)
            announce_install "$primary_pm" "$package"
            install_xbps_pkg "$mode" "$package" && return 0
            ;;
        zypper)
            announce_install "$primary_pm" "$package"
            install_zypper_pkg "$mode" "$package" && return 0
            ;;
        rpm-ostree)
            announce_install "$primary_pm" "$package"
            install_rpm_ostree_pkg "$mode" "$package" && return 0
            ;;
    esac
}

install_optionals_pkg() {
    assert_arity "$#" "ge" 1 "<mode=manual> <package>" || return 1

    local mode
    case "$1" in
        manual|auto)
            mode="$1"
            shift
            ;;
        *)
            mode="manual"
            ;;
    esac

    local package="$1"
    detect_system

    optionals=(
        toolbox
        flatpak
        snap
    )

    for option in "${optionals[@]}"; do
        case "$option" in
            toolbox)
                if [ "$toolbox_installed" -eq 1 ]; then
                    announce_install "$option" "$package"
                    install_toolbox_pkg "$mode" "$package" && return 0
                fi
                ;;
            flatpak)
                if [ "$flatpak_installed" -eq 1 ]; then
                    announce_install "$option" "$package"
                    install_flatpak_pkg "$mode" "$package" && return 0
                fi
                ;;
            snap)
                if [ "$snap_installed" -eq 1 ]; then
                    announce_install "$option" "$package"
                    install_snap_pkg "$mode" "$package" && return 0
                fi
                ;;
        esac
    done

    return 1
}

install_pkg() {
    assert_arity "$#" "ge" 1 "<mode=manual> <package>" || return 1

    local mode
    case "$1" in
        manual|auto)
            mode="$1"
            shift
            ;;
        *)
            mode="manual"
            ;;
    esac

    local package="$1"
    detect_system

    for package in "$@"; do
        case "$primary_pm" in
            rpm-ostree)
                install_optionals_pkg "$mode" "$package" && continue
                install_pm_pkg "$mode" "$package"
                ;;
            *)
                if [ -n "$secondary_pm" ]; then
                    install_sm_pkg "$mode" "$package" && continue
                else
                    install_pm_pkg "$mode" "$package" && continue
                fi

                install_optionals_pkg "$mode" "$package"
                ;;
        esac

        case "$package" in
            flatpak|snap|toolbox)
                detect_optionals
                ;;
            "nala")
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

ensure_packages() {
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
