# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

upgrade_nala() { sudo nala upgrade --full; }

upgrade_apt() { sudo apt update && sudo apt upgrade; }

upgrade_dnf() { sudo dnf upgrade; }

upgrade_eopkg() { sudo eopkg upgrade; }

upgrade_aur_helper() {
    detect_system
    "$secondary_pm" -Syu
}

upgrade_pacman() { sudo pacman -Syu; }

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

upgrade_rpm_ostree() { confirm sudo rpm-ostree upgrade; }

upgrade_flatpak() { flatpak update; }

upgrade_snap() { confirm sudo snap refresh; }

upgrade_toolbox() { toolbox run sudo dnf upgrade; }

upgrade_distrobox() { confirm distrobox-upgrade --all; }

upgrade_waydroid() { confirm sudo waydroid upgrade; }

upgrade_cinnamon_spices() { cinnamon-spice-updater --update-all; }

upgrade_fwupdmgr() { fwupdmgr refresh && fwupdmgr update; }

upgrade_sm() {
    detect_system
    case "$secondary_pm" in
        "nala")
            announce_upgrade "$secondary_pm"
            upgrade_nala "$package"
            ;;
        "paru"|"yay")
            announce_upgrade "$secondary_pm"
            upgrade_aur_helper "$package"
            ;;
    esac
}

upgrade_pm() {
    detect_system
    case "$primary_pm" in
        "apt")
            announce_upgrade "$primary_pm"
            upgrade_apt
            ;;
        "dnf")
            announce_upgrade "$primary_pm"
            upgrade_dnf
            ;;
        "eopkg")
            announce_upgrade "$primary_pm"
            upgrade_eopkg
            ;;
        "pacman")
            announce_upgrade "$primary_pm"
            upgrade_pacman
            ;;
        "xbps")
            announce_upgrade "$primary_pm"
            upgrade_xbps
            ;;
        "zypper")
            announce_upgrade "$primary_pm"
            upgrade_zypper
            ;;
        "rpm-ostree")
            announce_upgrade "$primary_pm"
            upgrade_rpm_ostree
            ;;
    esac
}

upgrade_optionals() {
    detect_system
    optionals=(
        "flatpak"
        "snap"
        "toolbox"
        "distrobox"
        "waydroid"
        "cinnamon-spice-updater"
        "fwupdmgr"
    )

    for option in "${optionals[@]}"; do
        case "$option" in
            "flatpak")
                if [ "$flatpak_installed" -eq 1 ]; then
                    announce_upgrade "$option"
                    upgrade_flatpak
                fi
                ;;
            "snap")
                if [ "$snap_installed" -eq 1 ]; then
                    announce_upgrade "$option"
                    upgrade_snap
                fi
                ;;
            "toolbox")
                if [ "$toolbox_installed" -eq 1 ]; then
                    announce_upgrade "$option"
                    upgrade_toolbox
                fi
                ;;
            "distrobox")
                if command -v distrobox >/dev/null 2>&1; then
                    announce_upgrade "$option"
                    upgrade_distrobox
                fi
                ;;
            "waydroid")
                if command -v waydroid >/dev/null 2>&1; then
                    announce_upgrade "$option"
                    upgrade_waydroid
                fi
                ;;
            "cinnamon-spice-updater")
                if command -v cinnamon-spice-updater >/dev/null 2>&1; then
                    announce_upgrade "$option"
                    upgrade_cinnamon_spices
                fi
                ;;
            "fwupdmgr")
                if command -v fwupdmgr >/dev/null 2>&1; then
                    announce_upgrade "$option"
                    upgrade_fwupdmgr
                fi
                ;;
        esac
    done
}

upgrade() {
    detect_system
    case "$primary_pm" in
        "rpm-ostree")
            upgrade_optionals
            upgrade_pm
            ;;
        *)
            if [ -n "$secondary_pm" ]; then
                upgrade_sm
            else
                upgrade_pm
            fi

            upgrade_optionals
            ;;
    esac
}
