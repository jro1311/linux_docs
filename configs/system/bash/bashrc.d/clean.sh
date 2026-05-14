# shellcheck shell=bash
# shellcheck disable=SC2015,SC2034,SC2154

_clean_nala() {
    local mode="$1"

    case "$mode" in
        auto)
            sudo nala autoremove -y && sudo nala clean || true
            ;;
        manual|*)
            sudo nala autoremove && sudo nala clean || true
            ;;
    esac

    return 0
}

_clean_apt() {
    local mode="$1"

    case "$mode" in
        auto)
            sudo apt-get autoremove -y && sudo apt-get clean || true
            ;;
        manual|*)
            sudo apt autoremove && sudo apt clean || true
            ;;
    esac

    return 0
}

_clean_dnf() {
    local mode="$1"

    case "$mode" in
        auto)
            sudo dnf autoremove -y && sudo dnf clean packages || true
            ;;
        manual|*)
            sudo dnf autoremove && sudo dnf clean packages || true
            ;;
    esac

    return 0
}

_clean_eopkg() {
    local mode="$1"

    case "$mode" in
        auto)
            sudo eopkg remove-orphans -y && sudo eopkg delete-cache || true
            ;;
        manual|*)
            sudo eopkg remove-orphans && sudo eopkg delete-cache || true
            ;;
    esac

    return 0
}

_clean_aur() {
    local mode="$1"

    case "$mode" in
        auto)
            if "$secondary_pm" -Qdtq >/dev/null 2>&1; then
                "$secondary_pm" -Qdtq | sudo xargs -r "$secondary_pm" -Rns --noconfirm || true
            else
                echo "No packages to remove."
            fi
            ;;
        manual|*)
            if "$secondary_pm" -Qdtq >/dev/null 2>&1; then
                "$secondary_pm" -Qdtq | sudo xargs -r "$secondary_pm" -Rns || true
            else
                echo "No packages to remove."
            fi
            ;;
    esac

    return 0
}

_clean_pacman() {
    local mode="$1"

    case "$mode" in
        auto)
            if pacman -Qdtq >/dev/null 2>&1; then
                pacman -Qdtq | sudo xargs -r pacman -Rns --noconfirm || true
            else
                echo "No packages to remove."
            fi
            ;;
        manual|*)
            if pacman -Qdtq >/dev/null 2>&1; then
                pacman -Qdtq | sudo xargs -r pacman -Rns || true
            else
                echo "No packages to remove."
            fi
            ;;
    esac

    return 0
}

_clean_xbps() {
    local mode="$1"

    case "$mode" in
        auto)
            sudo xbps-remove -Ooy || true
            ;;
        manual|*)
            sudo xbps-remove -Oo || true
            ;;
    esac

    return 0
}

_clean_zypper() {
    local mode="$1"

    case "$mode" in
        auto)
            sudo zypper purge-kernels -y && sudo zypper clean || true
            ;;
        manual|*)
            sudo zypper purge-kernels && sudo zypper clean || true
            ;;
    esac

    return 0
}

_clean_rpm_ostree() {
    local mode="$1"

    case "$mode" in
        auto)
            sudo rpm-ostree cleanup -bm || true
            ;;
        manual|*)
            confirm "Confirm cleanup operation [y/N]" sudo rpm-ostree cleanup -bm || true
            ;;
    esac

    return 0
}

_clean_toolbox() {
    local mode="$1"

    case "$mode" in
        auto)
            toolbox run sudo dnf autoremove -y && toolbox sudo dnf clean packages || true
            ;;
        manual|*)
            toolbox run sudo dnf autoremove && toolbox sudo dnf clean packages || true
            ;;
    esac

    return 0
}

_clean_flatpak() {
    local mode="$1"

    case "$mode" in
        auto)
            flatpak uninstall --unused -y || true
            ;;
        manual|*)
            flatpak uninstall --unused || true
            ;;
    esac

    return 0
}

clean_sm() {
    local mode="$1"

    case "$secondary_pm" in
        "nala")
            announce_clean "$secondary_pm"
            _clean_nala "$mode"
            ;;
        paru|yay)
            announce_clean "$secondary_pm"
            _clean_aur_helper "$mode"
            ;;
    esac
}

clean_pm() {
    local mode="$1"

    case "$primary_pm" in
        apt)
            announce_clean "$primary_pm"
            _clean_apt "$mode"
            ;;
        dnf)
            announce_clean "$primary_pm"
            _clean_dnf "$mode"
            ;;
        eopkg)
            announce_clean "$primary_pm"
            _clean_eopkg "$mode"
            ;;
        pacman)
            announce_clean "$primary_pm"
            _clean_pacman "$mode"
            ;;
        xbps)
            announce_clean "$primary_pm"
            _clean_xbps "$mode"
            ;;
        zypper)
            announce_clean "$primary_pm"
            _clean_zypper "$mode"
            ;;
        rpm-ostree)
            announce_clean "$primary_pm"
            _clean_rpm_ostree "$mode"
            ;;
    esac
}

clean_optionals() {
    local mode="$1"

    optionals=(
        toolbox
        flatpak
        snap
    )

    for option in "${optionals[@]}"; do
        case "$option" in
            toolbox)
                if [ "$toolbox_installed" -eq 1 ]; then
                    announce_clean "$option"
                    _clean_toolbox "$mode"
                fi
                ;;
            flatpak)
                if [ "$flatpak_installed" -eq 1 ]; then
                    announce_clean "$option"
                    _clean_flatpak "$mode"
                fi
                ;;
            snap)
                if [ "$snap_installed" -eq 1 ]; then
                    no_function_available "snap"
                fi
                ;;
        esac
    done
}

clean() {
    local mode="$1"
    detect_system

    case "$primary_pm" in
        rpm-ostree)
            clean_optionals "$mode"
            clean_pm "$mode"
            ;;
        *)
            if [ -n "$secondary_pm" ]; then
                clean_sm "$mode"
            else
                clean_pm "$mode"
            fi

            clean_optionals "$mode"
            ;;
    esac
}
