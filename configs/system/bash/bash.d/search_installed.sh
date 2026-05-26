# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_search_installed_nala() {
    local pkg="$1"
    nala list --installed "$pkg"
}

_search_installed_apt() {
    local pkg="$1"
    apt list --installed "$pkg"
}

_search_installed_dnf() {
    local pkg="$1"
    dnf list --installed "$pkg"
}

_search_installed_eopkg() {
    local pkg="$1"
    eopkg search -i "$pkg"
}

_search_installed_aur_pkg() {
    local pkg="$1"
    detect_system
    "$secondary_pm" -Qs "$pkg"
}

_search_installed_pacman() {
    local pkg="$1"
    pacman -Qs "$pkg"
}

_search_installed_xbps() {
    local pkg="$1"
    xbps-query -s "$pkg"
}

_search_installed_zypper() {
    local pkg="$1"
    zypper se -i "$pkg"
}

_search_installed_rpm_ostree() {
    local pkg="$1"
    rpm -qa "$pkg"
}

_search_installed_toolbox_pkg() {
    local pkg="$1"
    toolbox run dnf list --installed "$pkg"
}

_search_installed_flatpak_pkg() {
    local pkg="$1"
    flatpak list | grep -Fi "$pkg"
}

_search_installed_snap_pkg() {
    local pkg="$1"
    snap list "$pkg"
}

search_installed_sm() {
    local pkg="$1"

    case "$secondary_pm" in
        "nala")
            announce_search "$secondary_pm"
            _search_installed_nala "$pkg"
            ;;
        paru|yay)
            announce_search "$secondary_pm"
            _search_installed_aur_pkg "$pkg"
            ;;
    esac
}

search_installed_pm() {
    local pkg="$1"

    case "$primary_pm" in
        apt)
            announce_search "$primary_pm" "$pkg"
            _search_installed_apt "$pkg"
            ;;
        dnf)
            announce_search "$primary_pm" "$pkg"
            _search_installed_dnf "$pkg"
            ;;
        eopkg)
            announce_search "$primary_pm" "$pkg"
            _search_installed_eopkg "$pkg"
            ;;
        pacman)
            announce_search "$primary_pm" "$pkg"
            _search_installed_pacman "$pkg"
            ;;
        xbps)
            announce_search "$primary_pm" "$pkg"
            _search_installed_xbps "$pkg"
            ;;
        zypper)
            announce_search "$primary_pm" "$pkg"
            _search_installed_zypper "$pkg"
            ;;
        rpm-ostree)
            announce_search "$primary_pm" "$pkg"
            _search_installed_rpm_ostree "$pkg"
            ;;
    esac
}

search_installed_optionals() {
    local pkg="$1"

    optionals=(
        toolbox
        flatpak
        snap
    )

    for option in "${optionals[@]}"; do
        case "$option" in
            toolbox)
                if [ "$toolbox_installed" -eq 1 ]; then
                    announce_search "$option" "$pkg"
                    _search_installed_toolbox_pkg "$pkg"
                fi
                ;;
            flatpak)
                if [ "$flatpak_installed" -eq 1 ]; then
                    announce_search "$option" "$pkg"
                    _search_installed_flatpak_pkg "$pkg"
                fi
                ;;
            snap)
                if [ "$snap_installed" -eq 1 ]; then
                    announce_search "$option" "$pkg"
                    _search_installed_snap_pkg "$pkg"
                fi
                ;;
        esac
    done
}

search_installed() {
    assert_arity "$#" "eq" 1 "<pkg>" || return 1

    local pkg="$1"
    detect_system

    case "$primary_pm" in
        rpm-ostree)
            search_installed_optionals "$pkg"
            search_installed_pm "$pkg"
            ;;
        *)
            if [ -n "$secondary_pm" ]; then
                search_installed_sm "$pkg"
            else
                search_installed_pm "$pkg"
            fi

            search_installed_optionals "$pkg"
            ;;
    esac
}
