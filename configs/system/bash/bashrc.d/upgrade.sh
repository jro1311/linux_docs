# shellcheck shell=bash
# shellcheck disable=SC2015,SC2034,SC2154

_upgrade_nala() {
    local mode="$1"

    case "$mode" in
        auto)
            sudo nala upgrade --full -y || true
            ;;
        manual|*)
            sudo nala upgrade --full || true
            ;;
    esac

    return 0
}

_upgrade_apt() {
    local mode="$1"

    case "$mode" in
        auto)
            sudo apt-get update && sudo apt-get full-upgrade -y || true
            ;;
        manual|*)
            sudo apt update && sudo apt full-upgrade || true
            ;;
    esac

    return 0
}

_upgrade_dnf() {
    local mode="$1"

    case "$mode" in
        auto)
            sudo dnf upgrade -y || true
            ;;
        manual|*)
            sudo dnf upgrade || true
            ;;
    esac

    return 0
}

_upgrade_eopkg() {
    local mode="$1"

    case "$mode" in
        auto)
            sudo eopkg upgrade -y || true
            ;;
        manual|*)
            sudo eopkg upgrade || true
            ;;
    esac

    return 0
}

_upgrade_aur() {
    local mode="$1"

    case "$mode" in
        auto)
            "$secondary_pm" -Syu --noconfirm || true
            ;;
        manual|*)
            "$secondary_pm" -Syu || true
            ;;
    esac

    return 0
}

_upgrade_pacman() {
    local mode="$1"

    case "$mode" in
        auto)
            sudo pacman -Syu --noconfirm || true
            ;;
        manual|*)
            sudo pacman -Syu || true
            ;;
    esac

    return 0
}

_upgrade_xbps() {
    local mode="$1"

    case "$mode" in
        auto)
            sudo xbps-install -Suy xbps && sudo xbps-install -uy || true
            ;;
        manual|*)
            sudo xbps-install -Su xbps && sudo xbps-install -u || true
            ;;
    esac

    return 0
}

_upgrade_zypper() {
    local mode="$1"

    case "$mode" in
        auto)
            case "$os" in
                opensuse-tumbleweed|opensuse-slowroll)
                    sudo zypper ref && sudo zypper dup --remove-orphaned -y || true
                    ;;
                opensuse-leap)
                    sudo zypper ref && sudo zypper up -y || true
                    ;;
            esac
            ;;
        manual|*)
            case "$os" in
                opensuse-tumbleweed|opensuse-slowroll)
                    sudo zypper ref && sudo zypper dup --remove-orphaned || true
                    ;;
                opensuse-leap)
                    sudo zypper ref && sudo zypper up || true
                    ;;
            esac
            ;;
    esac

    return 0
}

_upgrade_rpm_ostree() {
    local mode="$1"

    case "$mode" in
        auto)
            sudo rpm-ostree upgrade || true
            ;;
        manual|*)
            confirm "Confirm upgrade operation [y/N]" sudo rpm-ostree upgrade || true
            ;;
    esac

    return 0
}

_upgrade_toolbox() {
    local mode="$1"

    case "$mode" in
        auto)
            toolbox run sudo dnf upgrade -y || true
            ;;
        manual|*)
            toolbox run sudo dnf upgrade || true
            ;;
    esac

    return 0
}

_upgrade_distrobox() {
    local mode="$1"

    case "$mode" in
        auto)
            distrobox-upgrade --all || true
            ;;
        manual|*)
            confirm "Confirm upgrade operation [y/N]" distrobox-upgrade --all || true
            ;;
    esac

    return 0
}

_upgrade_flatpak() {
    local mode="$1"

    case "$mode" in
        auto)
            flatpak update -y || true
            ;;
        manual|*)
            flatpak update || true
            ;;
    esac

    return 0
}

_upgrade_snap() {
    local mode="$1"

    case "$mode" in
        auto)
            sudo snap refresh || true
            ;;
        manual|*)
            confirm "Confirm upgrade operation [y/N]" sudo snap refresh || true
            ;;
    esac

    return 0
}

_upgrade_waydroid() {
    local mode="$1"

    case "$mode" in
        auto)
            sudo waydroid upgrade || true
            ;;
        manual|*)
            confirm "Confirm upgrade operation [y/N]" sudo waydroid upgrade || true
            ;;
    esac

    return 0
}

_upgrade_cinnamon_spices() {
    cinnamon-spice-updater --update-all || true
    return 0
}

_upgrade_fwupdmgr() {
    local mode="$1"

    case "$mode" in
        auto)
            fwupdmgr refresh && fwupdmgr update -y || true
            ;;
        manual|*)
            fwupdmgr refresh && fwupdmgr update || true
            ;;
    esac

    return 0
}

upgrade_sm() {
    local mode="$1"

    case "$secondary_pm" in
        "nala")
            announce_upgrade "$secondary_pm"
            _upgrade_nala "$mode"
            ;;
        paru|yay)
            announce_upgrade "$secondary_pm"
            _upgrade_aur_helper "$mode"
            ;;
    esac
}

upgrade_pm() {
    local mode="$1"

    case "$primary_pm" in
        apt)
            announce_upgrade "$primary_pm"
            _upgrade_apt "$mode"
            ;;
        dnf)
            announce_upgrade "$primary_pm"
            _upgrade_dnf "$mode"
            ;;
        eopkg)
            announce_upgrade "$primary_pm"
            _upgrade_eopkg "$mode"
            ;;
        pacman)
            announce_upgrade "$primary_pm"
            _upgrade_pacman "$mode"
            ;;
        xbps)
            announce_upgrade "$primary_pm"
            _upgrade_xbps "$mode"
            ;;
        zypper)
            announce_upgrade "$primary_pm"
            _upgrade_zypper "$mode"
            ;;
        rpm-ostree)
            announce_upgrade "$primary_pm"
            _upgrade_rpm_ostree "$mode"
            ;;
    esac
}

upgrade_optionals() {
    local mode="$1"

    optionals=(
        toolbox
        distrobox
        flatpak
        snap
        waydroid
        cinnamon-spice-updater
        fwupdmgr
    )

    for option in "${optionals[@]}"; do
        case "$option" in
            toolbox)
                if [ "$toolbox_installed" -eq 1 ]; then
                    announce_upgrade "$option"
                    _upgrade_toolbox "$mode"
                fi
                ;;
            "distrobox")
                if command -v distrobox >/dev/null 2>&1; then
                    announce_upgrade "$option"
                    _upgrade_distrobox "$mode"
                fi
                ;;
            flatpak)
                if [ "$flatpak_installed" -eq 1 ]; then
                    announce_upgrade "$option"
                    _upgrade_flatpak "$mode"
                fi
                ;;
            snap)
                if [ "$snap_installed" -eq 1 ]; then
                    announce_upgrade "$option"
                    _upgrade_snap "$mode"
                fi
                ;;
            "waydroid")
                if command -v waydroid >/dev/null 2>&1; then
                    announce_upgrade "$option"
                    _upgrade_waydroid "$mode"
                fi
                ;;
            "cinnamon-spice-updater")
                if command -v cinnamon-spice-updater >/dev/null 2>&1; then
                    announce_upgrade "$option"
                    _upgrade_cinnamon_spices "$mode"
                fi
                ;;
            "fwupdmgr")
                if command -v fwupdmgr >/dev/null 2>&1; then
                    announce_upgrade "$option"
                    _upgrade_fwupdmgr "$mode"
                fi
                ;;
        esac
    done
}

upgrade() {
    local mode="$1"
    detect_system

    case "$primary_pm" in
        rpm-ostree)
            upgrade_optionals "$mode"
            upgrade_pm "$mode"
            ;;
        *)
            if [ -n "$secondary_pm" ]; then
                upgrade_sm "$mode"
            else
                upgrade_pm "$mode"
            fi

            upgrade_optionals "$mode"
            ;;
    esac
}
