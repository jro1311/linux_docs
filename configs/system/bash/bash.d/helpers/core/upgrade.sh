# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_upgrade_pm_bypass() {
    announce_upgrade "$primary_pm"

    case "$primary_pm" in
        apt)
            sudo apt-get update             >/dev/null || :
            sudo apt-get full-upgrade -y    >/dev/null || :
            ;;
        dnf)
            sudo dnf upgrade -y >/dev/null || :
            ;;
        eopkg)
            sudo eopkg upgrade -y >/dev/null || :
            ;;
        pacman)
            sudo pacman -Syu --noconfirm >/dev/null || :
            ;;
        xbps)
            sudo xbps-install -Suy xbps >/dev/null || :
            sudo xbps-install -uy       >/dev/null || :
            ;;
        zypper)
            case "$os" in
                opensuse-tumbleweed|opensuse-slowroll)
                    sudo zypper ref                         >/dev/null || :
                    sudo zypper dup --remove-orphaned -y    >/dev/null || :
                    ;;
                opensuse-leap)
                    sudo zypper ref     >/dev/null || :
                    sudo zypper up -y   >/dev/null || :
                    ;;
            esac
            ;;
        rpm-ostree)
            sudo rpm-ostree upgrade >/dev/null || :
            ;;
    esac
}

_upgrade_aur_bypass() {
    [ "$primary_pm" != "pacman" ] && return 0
    [ -z "$secondary_pm" ] && return 0

    announce_upgrade "$secondary_pm"
    "$secondary_pm" -Syu --noconfirm >/dev/null || :
}

_upgrade_toolbox_bypass() {
    [ "$toolbox_installed" -eq 0 ] && return 0

    announce_upgrade "toolbox"
    toolbox run sudo dnf upgrade -y >/dev/null || :
}

_upgrade_distrobox_bypass() {
    command -v distrobox >/dev/null 2>&1 || return 0

    announce_upgrade "distrobox"
    distrobox-upgrade --all >/dev/null || :
}

_upgrade_flatpak_bypass() {
    [ "$flatpak_installed" -eq 0 ] && return 0

    announce_upgrade "flatpak"
    flatpak update -y >/dev/null || :
}

_upgrade_snap_bypass() {
    [ "$snap_installed" -eq 0 ] && return 0

    announce_upgrade "snap"
    sudo snap refresh >/dev/null || :
}

_upgrade_waydroid_bypass() {
    command -v waydroid >/dev/null 2>&1 || return 0

    announce_upgrade "waydroid"
    sudo waydroid upgrade >/dev/null || :
}

_upgrade_cinnamon_spices_bypass() {
    command -v cinnamon-spice-updater >/dev/null 2>&1 || return 0

    announce_upgrade "cinnamon-spice-updater"
    cinnamon-spice-updater --update-all >/dev/null || :
}

_upgrade_fwupdmgr_bypass() {
    command -v fwupdmgr >/dev/null 2>&1 || return 0

    announce_upgrade "fwupdmgr"
    fwupdmgr refresh 2>/dev/null 2>&1 || :
    fwupdmgr update -y >/dev/null || :
}

_upgrade_optionals_bypass() {
    _upgrade_toolbox_bypass
    _upgrade_distrobox_bypass
    _upgrade_flatpak_bypass
    _upgrade_snap_bypass
    _upgrade_waydroid_bypass
    _upgrade_cinnamon_spices_bypass
    _upgrade_fwupdmgr_bypass
}

upgrade_bypass() {
    detect_system

    _upgrade_pm_bypass
    _upgrade_aur_bypass
    _upgrade_optionals_bypass
}
