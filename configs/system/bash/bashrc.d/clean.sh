# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

clean_nala() {
    local mode="$1"
    case "$mode" in
        auto)
            sudo nala autoremove -y && sudo nala clean
            ;;
        manual|*)
            sudo nala autoremove && sudo nala clean
            ;;
    esac

    return 0
}

clean_apt() {
    local mode="$1"
    case "$mode" in
        auto)
            sudo apt-get autoremove -y && sudo apt-get clean
            ;;
        manual|*)
            sudo apt autoremove && sudo apt clean
            ;;
    esac

    return 0
}

clean_dnf() {
    local mode="$1"
    case "$mode" in
        auto)
            sudo dnf autoremove -y && sudo dnf clean packages
            ;;
        manual|*)
            sudo dnf autoremove && sudo dnf clean packages
            ;;
    esac

    return 0
}

clean_eopkg() {
    local mode="$1"
    case "$mode" in
        auto)
            sudo eopkg remove-orphans -y && sudo eopkg delete-cache
            ;;
        manual|*)
            sudo eopkg remove-orphans && sudo eopkg delete-cache
            ;;
    esac

    return 0
}

clean_aur_helper() {
    local mode="$1"
    detect_system
    case "$mode" in
        auto)
            if "$secondary_pm" -Qdtq >/dev/null 2>&1; then
                "$secondary_pm" -Qdtq | sudo xargs -r "$secondary_pm" -Rns --noconfirm
            else
                echo "No packages to remove."
            fi
            ;;
        manual|*)
            if "$secondary_pm" -Qdtq >/dev/null 2>&1; then
                "$secondary_pm" -Qdtq | sudo xargs -r "$secondary_pm" -Rns
            else
                echo "No packages to remove."
            fi
            ;;
    esac

    return 0
}

clean_pacman() {
    local mode="$1"
    case "$mode" in
        auto)
            if pacman -Qdtq >/dev/null 2>&1; then
                pacman -Qdtq | sudo xargs -r pacman -Rns --noconfirm
            else
                echo "No packages to remove."
            fi
            ;;
        manual|*)
            if pacman -Qdtq >/dev/null 2>&1; then
                pacman -Qdtq | sudo xargs -r pacman -Rns
            else
                echo "No packages to remove."
            fi
            ;;
    esac

    return 0
}

clean_xbps() {
    local mode="$1"
    case "$mode" in
        auto)
            sudo xbps-remove -Ooy
            ;;
        manual|*)
            sudo xbps-remove -Oo
            ;;
    esac

    return 0
}

clean_zypper() {
    local mode="$1"
    case "$mode" in
        auto)
            sudo zypper purge-kernels -y && sudo zypper clean
            ;;
        manual|*)
            sudo zypper purge-kernels && sudo zypper clean
            ;;
    esac

    return 0
}

clean_rpm_ostree() {
    local mode="$1"
    case "$mode" in
        auto)
            sudo rpm-ostree cleanup -bm
            ;;
        manual|*)
            confirm "Confirm cleanup operation [y/N]" sudo rpm-ostree cleanup -bm
            ;;
    esac

    return 0
}

clean_toolbox() {
    local mode="$1"
    case "$mode" in
        auto)
            toolbox run sudo dnf autoremove -y && toolbox sudo dnf clean packages
            ;;
        manual|*)
            toolbox run sudo dnf autoremove && toolbox sudo dnf clean packages
            ;;
    esac

    return 0
}

clean_flatpak() {
    local mode="$1"
    case "$mode" in
        auto)
            flatpak uninstall --unused -y
            ;;
        manual|*)
            flatpak uninstall --unused
            ;;
    esac

    return 0
}

clean_sm() {
    local mode="$1"
    detect_system

    case "$secondary_pm" in
        "nala")
            announce_clean "$secondary_pm"
            clean_nala "$mode"
            ;;
        paru|yay)
            announce_clean "$secondary_pm"
            clean_aur_helper "$mode"
            ;;
    esac
}

clean_pm() {
    local mode="$1"
    detect_system

    case "$primary_pm" in
        apt)
            announce_clean "$primary_pm"
            clean_apt "$mode"
            ;;
        dnf)
            announce_clean "$primary_pm"
            clean_dnf "$mode"
            ;;
        eopkg)
            announce_clean "$primary_pm"
            clean_eopkg "$mode"
            ;;
        pacman)
            announce_clean "$primary_pm"
            clean_pacman "$mode"
            ;;
        xbps)
            announce_clean "$primary_pm"
            clean_xbps "$mode"
            ;;
        zypper)
            announce_clean "$primary_pm"
            clean_zypper "$mode"
            ;;
        rpm-ostree)
            announce_clean "$primary_pm"
            clean_rpm_ostree "$mode"
            ;;
    esac
}

clean_optionals() {
    local mode="$1"
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
                    announce_clean "$option"
                    clean_toolbox "$mode"
                fi
                ;;
            flatpak)
                if [ "$flatpak_installed" -eq 1 ]; then
                    announce_clean "$option"
                    clean_flatpak "$mode"
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
