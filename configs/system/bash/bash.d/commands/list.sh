# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_list_nala() { nala list --installed; }

_list_apt() { apt list --installed; }

_list_dnf() { dnf list --installed; }

_list_eopkg() { eopkg list-installed; }

_list_aur() {
    detect_system
    "$secondary_pm" -Qs
}

_list_pacman() { pacman -Qs; }

_list_xbps() { xbps-query -sl; }

_list_zypper() { zypper se -i; }

_list_rpm_ostree() { rpm -qa; }

_list_toolbox() { toolbox run dnf list --installed; }

_list_flatpak() { flatpak list; }

_list_snap() { snap list; }

list_sm() {
    case "$secondary_pm" in
        nala)
            announce_list "$secondary_pm"
            _list_nala
            ;;
        paru|yay)
            announce_list "$secondary_pm"
            _list_aur_helper
            ;;
    esac
}

list_pm() {
    case "$primary_pm" in
        apt)
            announce_list "$primary_pm"
            _list_apt
            ;;
        dnf)
            announce_list "$primary_pm"
            _list_dnf
            ;;
        eopkg)
            announce_list "$primary_pm"
            _list_eopkg
            ;;
        pacman)
            announce_list "$primary_pm"
            _list_pacman
            ;;
        xbps)
            announce_list "$primary_pm"
            _list_xbps
            ;;
        zypper)
            announce_list "$primary_pm"
            _list_zypper
            ;;
        rpm-ostree)
            announce_list "$primary_pm"
            _list_rpm_ostree
            ;;
    esac
}

list_optionals() {
    local option
    local -a optionals=(
        toolbox
        flatpak
        snap
    )

    for option in "${optionals[@]}"; do
        case "$option" in
            toolbox)
                if [ "$toolbox_installed" -eq 1 ]; then
                    announce_list "$option"
                    _list_toolbox
                fi
                ;;
            flatpak)
                if [ "$flatpak_installed" -eq 1 ]; then
                    announce_list "$option"
                    _list_flatpak
                fi
                ;;
            snap)
                if [ "$snap_installed" -eq 1 ]; then
                    announce_list "$option"
                    _list_snap
                fi
                ;;
        esac
    done
}

list() {
    detect_system

    case "$primary_pm" in
        rpm-ostree)
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
