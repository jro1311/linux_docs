# shellcheck shell=bash
# shellcheck disable=SC2015,SC2034,SC2154

_upgrade_nala() {
    local mode="${1:-manual}"
    local flags=(--full)

    [ "$mode" = "auto" ] && flags+=(-y)

    sudo nala upgrade "${flags[@]}" || :
}

_upgrade_apt() {
    local mode="${1:-manual}"
    local flags=()

    [ "$mode" = "auto" ] && flags+=(-y)

    if [ "$mode" = "auto" ]; then
        sudo apt-get update && sudo apt-get full-upgrade "${flags[@]}" || :
    else
        sudo apt update && sudo apt full-upgrade || :
    fi
}

_upgrade_dnf() {
    local mode="${1:-manual}"
    local flags=()

    [ "$mode" = "auto" ] && flags+=(-y)

    sudo dnf upgrade "${flags[@]}" || :
}

_upgrade_eopkg() {
    local mode="${1:-manual}"
    local flags=()

    [ "$mode" = "auto" ] && flags+=(-y)

    sudo eopkg upgrade "${flags[@]}" || :
}

_upgrade_aur() {
    local mode="${1:-manual}"
    local flags=(-Syu)

    [ "$mode" = "auto" ] && flags+=(--noconfirm)

    "$secondary_pm" "${flags[@]}" || :
}

_upgrade_pacman() {
    local mode="${1:-manual}"
    local flags=(-Syu)

    [ "$mode" = "auto" ] && flags+=(--noconfirm)

    sudo pacman "${flags[@]}" || :
}

_upgrade_xbps() {
    local mode="${1:-manual}"
    local flags=()

    [ "$mode" = "auto" ] && flags+=(-y)

    sudo xbps-install -Su "${flags[@]}" xbps && \
    sudo xbps-install -u "${flags[@]}" || :
}

_upgrade_zypper() {
    local mode="${1:-manual}"
    local flags=()

    [ "$mode" = "auto" ] && flags+=(-y)

    case "$os" in
        opensuse-tumbleweed|opensuse-slowroll)
            sudo zypper ref && sudo zypper dup --remove-orphaned "${flags[@]}" || :
            ;;
        opensuse-leap)
            sudo zypper ref && sudo zypper up "${flags[@]}" || :
            ;;
    esac
}

_upgrade_rpm_ostree() {
    local mode="${1:-manual}"

    if [ "$mode" = "manual" ]; then
        confirm "Confirm upgrade operation [y/N]" && sudo rpm-ostree upgrade || :
    else
        sudo rpm-ostree upgrade || :
    fi
}

_upgrade_toolbox() {
    local mode="${1:-manual}"
    local flags=()

    [ "$mode" = "auto" ] && flags+=(-y)

    toolbox run sudo dnf upgrade "${flags[@]}" || :
}

_upgrade_distrobox() {
    local mode="${1:-manual}"

    if [ "$mode" = "manual" ]; then
        confirm "Confirm upgrade operation [y/N]" && distrobox-upgrade --all || :
    else
        distrobox-upgrade --all || :
    fi
}

_upgrade_flatpak() {
    local mode="${1:-manual}"
    local flags=()

    [ "$mode" = "auto" ] && flags+=(-y)

    flatpak update "${flags[@]}" || :
}

_upgrade_snap() {
    local mode="${1:-manual}"

    if [ "$mode" = "manual" ]; then
        confirm "Confirm upgrade operation [y/N]" && sudo snap refresh || :
    else
        sudo snap refresh || :
    fi
}

_upgrade_waydroid() {
    local mode="${1:-manual}"

    if [ "$mode" = "manual" ]; then
        confirm "Confirm upgrade operation [y/N]" && sudo waydroid upgrade || :
    else
        sudo waydroid upgrade || :
    fi
}

_upgrade_cinnamon_spices() {
    cinnamon-spice-updater --update-all || :
}

_upgrade_fwupdmgr() {
    local mode="${1:-manual}"
    local flags=()

    [ "$mode" = "auto" ] && flags+=(-y)

    fwupdmgr refresh && fwupdmgr update "${flags[@]}" || :
}

upgrade_sm() {
    local mode="${1:-manual}"

    case "$secondary_pm" in
        nala)
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
    local mode="${1:-manual}"

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
    local mode="${1:-manual}"
    local option
    local -a optionals=(
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
            distrobox)
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
            waydroid)
                if command -v waydroid >/dev/null 2>&1; then
                    announce_upgrade "$option"
                    _upgrade_waydroid "$mode"
                fi
                ;;
            cinnamon-spice-updater)
                if command -v cinnamon-spice-updater >/dev/null 2>&1; then
                    announce_upgrade "$option"
                    _upgrade_cinnamon_spices "$mode"
                fi
                ;;
            fwupdmgr)
                if command -v fwupdmgr >/dev/null 2>&1; then
                    announce_upgrade "$option"
                    _upgrade_fwupdmgr "$mode"
                fi
                ;;
        esac
    done
}

upgrade() {
    local mode="${1:-manual}"
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
