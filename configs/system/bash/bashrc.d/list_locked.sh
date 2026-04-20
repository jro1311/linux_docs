# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

list_locked_apt() { apt-mark showhold; }

list_locked_dnf() { dnf versionlock list; }

list_locked_pacman() { grep -F "IgnorePkg" /etc/pacman.conf; }

list_locked_xbps() { xbps-query -H; }

list_locked_zypper() { zypper ll; }

list_locked_toolbox() { toolbox run sudo dnf versionlock list; }

list_locked_flatpak() { flatpak mask; }

list_locked_snap() { snap list | grep -F "held"; }

list_locked_pm() {
    detect_system
    case "$primary_pm" in
        "apt")
            announce_list_locked "$primary_pm"
            list_locked_apt
            ;;
        "dnf")
            announce_list_locked "$primary_pm"
            list_locked_dnf
            ;;
        "eopkg")
            no_function_available
            ;;
        "pacman")
            announce_list_locked "$primary_pm"
            list_locked_pacman
            ;;
        "xbps")
            announce_list_locked "$primary_pm"
            list_locked_xbps
            ;;
        "zypper")
            announce_list_locked "$primary_pm"
            list_locked_zypper
            ;;
        "rpm-ostree")
            no_function_available
            ;;
    esac
}

list_locked_optionals() {
    detect_system
    optionals=(
        "toolbox"
        "flatpak"
        "snap"
    )

    for option in "${optionals[@]}"; do
        case "$option" in
            "toolbox")
                if [ "$toolbox_installed" -eq 1 ]; then
                    announce_list_locked "$option"
                    list_locked_toolbox
                fi
                ;;
            "flatpak")
                if [ "$flatpak_installed" -eq 1 ]; then
                    announce_list_locked "$option"
                    list_locked_flatpak
                fi
                ;;
            "snap")
                if [ "$snap_installed" -eq 1 ]; then
                    announce_list_locked "$option"
                    list_locked_snap
                fi
                ;;
        esac
    done
}

list_locked() {
    detect_system
    case "$primary_pm" in
        "rpm-ostree")
            list_locked_optionals
            list_locked_pm
            ;;
        *)
            list_locked_pm
            list_locked_optionals
            ;;
    esac
}
