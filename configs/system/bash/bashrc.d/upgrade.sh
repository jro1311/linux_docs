# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

upgrade_apt() {
    detect_system
    case "$secondary_pm" in
        "nala")
            sudo nala upgrade --full
            ;;
        *)
            sudo apt update && sudo apt upgrade
            ;;
    esac
}

upgrade_dnf() { sudo dnf upgrade; }

upgrade_eopkg() { sudo eopkg upgrade; }

upgrade_pacman() {
    detect_system
    case "$secondary_pm" in
        "paru"|"yay")
            "$secondary_pm" -Syu
            ;;
        *)
            sudo pacman -Syu
            ;;
    esac
}

upgrade_xbps() { sudo xbps-install -Su xbps && sudo xbps-install -u; }

upgrade_zypper() {
    detect_system
    case "$os" in
        "opensuse-tumbleweed"|"opensuse-slowroll")
            sudo zypper ref && sudo zypper dup --remove-orphaned
            ;;
        "opensuse-leap")
            sudo zypper ref && sudo zypper up
            ;;
    esac
}

upgrade_flatpak() { flatpak update; }

upgrade_snap() { confirm sudo snap refresh; }

upgrade_distrobox() { confirm distrobox-upgrade --all; }

upgrade_toolbox() { toolbox run sudo dnf upgrade; }

upgrade_waydroid() { confirm sudo waydroid upgrade; }

upgrade_cinnamon_spices() { cinnamon-spice-updater --update-all; }

upgrade_fwupdmgr() { fwupdmgr refresh && fwupdmgr update; }

upgrade_rpm_ostree() { confirm sudo rpm-ostree upgrade; }

upgrade() {
    detect_system
    local managers=(apt dnf eopkg pacman xbps zypper flatpak snap distrobox toolbox waydroid cinnamon-spice-updater fwupdmgr rpm-ostree)

    for manager in "${managers[@]}"; do
        local upgrading="${green}$manager:${reset} upgrading packages"

        case "$manager" in
            "apt")
                if [ "$primary_pm" = "apt" ]; then
                    echo "$upgrading"
                    upgrade_apt
                fi
                ;;
            "dnf")
                if [ "$primary_pm" = "dnf" ]; then
                    echo "$upgrading"
                    upgrade_dnf
                fi
                ;;
            "eopkg")
                if [ "$primary_pm" = "eopkg" ]; then
                    echo "$upgrading"
                    upgrade_eopkg
                fi
                ;;
            "pacman")
                if [ "$primary_pm" = "pacman" ]; then
                    echo "$upgrading"
                    upgrade_pacman
                fi
                ;;
            "xbps")
                if [ "$primary_pm" = "xbps" ]; then
                    echo "$upgrading"
                    upgrade_xbps
                fi
                ;;
            "zypper")
                if [ "$primary_pm" = "zypper" ]; then
                    echo "$upgrading"
                    upgrade_zypper
                fi
                ;;
            "flatpak")
                if [ "$flatpak_installed" -eq 1 ]; then
                    echo "$upgrading"
                    upgrade_flatpak
                fi
                ;;
            "snap")
                if [ "$snap_installed" -eq 1 ]; then
                    echo "$upgrading"
                    upgrade_snap
                fi
                ;;
            "distrobox")
                if command -v distrobox >/dev/null 2>&1; then
                    echo "$upgrading"
                    upgrade_distrobox
                fi
                ;;
            "toolbox")
                if [ "$toolbox_installed" -eq 1 ]; then
                    echo "$upgrading"
                    upgrade_toolbox
                fi
                ;;
            "waydroid")
                if command -v waydroid >/dev/null 2>&1; then
                    echo "$upgrading"
                    upgrade_waydroid
                fi
                ;;
            "cinnamon-spice-updater")
                if command -v cinnamon-spice-updater >/dev/null 2>&1; then
                    echo "$upgrading"
                    upgrade_cinnamon_spices
                fi
                ;;
            "fwupdmgr")
                if command -v fwupdmgr >/dev/null 2>&1; then
                    echo "$upgrading"
                    upgrade_fwupdmgr
                fi
                ;;
            "rpm-ostree")
                if [ "$primary_pm" = "rpm-ostree" ]; then
                    echo "$upgrading"
                    upgrade_rpm_ostree
                fi
                ;;
        esac
    done
}
