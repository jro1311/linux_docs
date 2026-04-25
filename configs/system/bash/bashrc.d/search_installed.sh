# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_search_installed_nala() {
    local package="$1"
    nala list --installed "$package"
}

_search_installed_apt() {
    local package="$1"
    apt list --installed "$package"
}

_search_installed_dnf() {
    local package="$1"
    dnf list --installed "$package"
}

_search_installed_eopkg() {
    local package="$1"
    eopkg search -i "$package"
}

_search_installed_aur_pkg() {
    local package="$1"
    detect_system
    "$secondary_pm" -Qs "$package"
}

_search_installed_pacman() {
    local package="$1"
    pacman -Qs "$package"
}

_search_installed_xbps() {
    local package="$1"
    xbps-query -s "$package"
}

_search_installed_zypper() {
    local package="$1"
    zypper se -i "$package"
}

_search_installed_rpm_ostree() {
    local package="$1"
    rpm -qa | grep -i "^$package"
}

_search_installed_toolbox_pkg() {
    local package="$1"
    toolbox run dnf list --installed "$package"
}

_search_installed_flatpak_pkg() {
    local package="$1"
    flatpak list | grep -Fi "$package"
}

_search_installed_snap_pkg() {
    local package="$1"
    snap list "$package"
}

search_installed_sm() {
    local package="$1"

    case "$secondary_pm" in
        "nala")
            announce_list "$secondary_pm"
            search_installed_nala "$package"
            ;;
        paru|yay)
            announce_list "$secondary_pm"
            search_installed_aur_pkg "$package"
            ;;
    esac
}

search_installed_pm() {
    local package="$1"

    case "$primary_pm" in
        apt)
            announce_search "$primary_pm" "$package"
            _search_installed_apt "$package"
            ;;
        dnf)
            announce_search "$primary_pm" "$package"
            _search_installed_dnf "$package"
            ;;
        eopkg)
            announce_search "$primary_pm" "$package"
            _search_installed_eopkg "$package"
            ;;
        pacman)
            announce_search "$primary_pm" "$package"
            _search_installed_pacman "$package"
            ;;
        xbps)
            announce_search "$primary_pm" "$package"
            _search_installed_xbps "$package"
            ;;
        zypper)
            announce_search "$primary_pm" "$package"
            _search_installed_zypper "$package"
            ;;
        rpm-ostree)
            announce_search "$primary_pm" "$package"
            _search_installed_rpm_ostree "$package"
            ;;
    esac
}

search_installed_optionals() {
    local package="$1"

    optionals=(
        toolbox
        flatpak
        snap
    )

    for option in "${optionals[@]}"; do
        case "$option" in
            toolbox)
                if [ "$toolbox_installed" -eq 1 ]; then
                    announce_search "$option" "$package"
                    _search_installed_toolbox_pkg "$package"
                fi
                ;;
            flatpak)
                if [ "$flatpak_installed" -eq 1 ]; then
                    announce_search "$option" "$package"
                    _search_installed_flatpak_pkg "$package"
                fi
                ;;
            snap)
                if [ "$snap_installed" -eq 1 ]; then
                    announce_search "$option" "$package"
                    _search_installed_snap_pkg "$package"
                fi
                ;;
        esac
    done
}

search_installed() {
    assert_arity "$#" "eq" 1 "<package>" || return 1

    local package="$1"
    detect_system

    case "$primary_pm" in
        rpm-ostree)
            search_installed_optionals "$package"
            search_installed_pm "$package"
            ;;
        *)
            if [ -n "$secondary_pm" ]; then
                search_installed_sm "$package"
            else
                search_installed_pm "$package"
            fi

            search_installed_optionals "$package"
            ;;
    esac
}
