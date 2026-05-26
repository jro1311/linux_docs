# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_list_locked_apt() { apt-mark showhold; }

_list_locked_dnf() { dnf versionlock list; }

_list_locked_pacman() { grep -F "IgnorePkg" /etc/pacman.conf; }

_list_locked_xbps() { xbps-query -H; }

_list_locked_zypper() { zypper ll; }

_list_locked_toolbox() { toolbox run sudo dnf versionlock list; }

_list_locked_flatpak() { flatpak mask; }

_list_locked_snap() { snap list | grep -F "held"; }

list_locked_pm() {
    case "$primary_pm" in
        apt)
            announce_list_locked "$primary_pm"
            _list_locked_apt
            ;;
        dnf)
            announce_list_locked "$primary_pm"
            _list_locked_dnf
            ;;
        eopkg)
            no_function_available "$primary_pm"
            ;;
        pacman)
            announce_list_locked "$primary_pm"
            _list_locked_pacman
            ;;
        xbps)
            announce_list_locked "$primary_pm"
            _list_locked_xbps
            ;;
        zypper)
            announce_list_locked "$primary_pm"
            _list_locked_zypper
            ;;
        rpm-ostree)
            no_function_available "$primary_pm"
            ;;
    esac
}

list_locked_optionals() {
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
                    announce_list_locked "$option"
                    _list_locked_toolbox
                fi
                ;;
            flatpak)
                if [ "$flatpak_installed" -eq 1 ]; then
                    announce_list_locked "$option"
                    _list_locked_flatpak
                fi
                ;;
            snap)
                if [ "$snap_installed" -eq 1 ]; then
                    announce_list_locked "$option"
                    _list_locked_snap
                fi
                ;;
        esac
    done
}

list_locked() {
    detect_system

    case "$primary_pm" in
        rpm-ostree)
            list_locked_optionals
            list_locked_pm
            ;;
        *)
            list_locked_pm
            list_locked_optionals
            ;;
    esac
}
