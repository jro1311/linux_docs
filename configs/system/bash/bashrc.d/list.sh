# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

list_nala() { nala list --installed; }

list_apt() { apt list --installed; }

list_dnf() { dnf list --installed; }

list_eopkg() { eopkg list-installed; }

list_aur_helper() {
    detect_system
    "$secondary_pm" -Qs
}

list_pacman() { pacman -Qs; }

list_xbps() { xbps-query -sl; }

list_zypper() { zypper se -i; }

list_rpm_ostree() { rpm -qa; }

list_toolbox() { toolbox run dnf list --installed; }

list_flatpak() { flatpak list; }

list_snap() { snap list; }

list_sm() {
    detect_system
    case "$secondary_pm" in
        "nala")
            announce_list "$secondary_pm"
            list_nala "$package"
            ;;
        "paru"|"yay")
            announce_list "$secondary_pm"
            list_aur_helper "$package"
            ;;
    esac
}

list_pm() {
    detect_system
    case "$primary_pm" in
        "apt")
            announce_list "$primary_pm"
            list_apt
            ;;
        "dnf")
            announce_list "$primary_pm"
            list_dnf
            ;;
        "eopkg")
            announce_list "$primary_pm"
            list_eopkg
            ;;
        "pacman")
            announce_list "$primary_pm"
            list_pacman
            ;;
        "xbps")
            announce_list "$primary_pm"
            list_xbps
            ;;
        "zypper")
            announce_list "$primary_pm"
            list_zypper
            ;;
        "rpm-ostree")
            announce_list "$primary_pm"
            list_rpm_ostree
            ;;
    esac
}

list_optionals() {
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
                    announce_list "$option"
                    list_toolbox
                fi
                ;;
            "flatpak")
                if [ "$flatpak_installed" -eq 1 ]; then
                    announce_list "$option"
                    list_flatpak
                fi
                ;;
            "snap")
                if [ "$snap_installed" -eq 1 ]; then
                    announce_list "$option"
                    list_snap
                fi
                ;;
        esac
    done
}

list() {
    detect_system
    case "$primary_pm" in
        "rpm-ostree")
            list_optionals
            list_pm
            ;;
        *)
            if [ -n "$secondary_pm" ]; then
                list_sm
            else
                list_pm
            fi

            list_optionals
            ;;
    esac
}
