# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_search_nala() {
    local pkg="$1"
    nala search "$pkg"
}

_search_apt() {
    local pkg="$1"
    apt search "$pkg"
}

_search_dnf() {
    local pkg="$1"
    dnf search "$pkg"
}

_search_eopkg() {
    local pkg="$1"
    eopkg search "$pkg"
}

_search_aur_pkg() {
    local pkg="$1"
    "$secondary_pm" -Ss "$pkg"
}

_search_pacman() {
    local pkg="$1"
    pacman -Ss "$pkg"
}

_search_xbps() {
    local pkg="$1"
    xbps-query -Rs "$pkg"
}

_search_zypper() {
    local pkg="$1"
    zypper se "$pkg"
}

_search_rpm_ostree() {
    local pkg="$1"
    rpm-ostree search "$pkg"
}

_search_toolbox_pkg() {
    local pkg="$1"
    toolbox run dnf search "$pkg"
}

_search_flatpak_pkg() {
    local pkg="$1"
    flatpak search "$pkg"
}

_search_snap_pkg() {
    local pkg="$1"
    snap find "$pkg"
}

search_sm() {
    local pkg="$1"

    case "$secondary_pm" in
        nala)
            announce_search "$secondary_pm"
            _search_nala "$pkg"
            ;;
        yay|paru|pikaur|aura)
            announce_search "$secondary_pm"
            _search_aur_pkg "$pkg"
            ;;
    esac
}

search_pm() {
    local pkg="$1"

    case "$primary_pm" in
        apt)
            announce_search "$primary_pm" "$pkg"
            _search_apt "$pkg"
            ;;
        dnf)
            announce_search "$primary_pm" "$pkg"
            _search_dnf "$pkg"
            ;;
        eopkg)
            announce_search "$primary_pm" "$pkg"
            _search_eopkg "$pkg"
            ;;
        pacman)
            announce_search "$primary_pm" "$pkg"
            _search_pacman "$pkg"
            ;;
        xbps)
            announce_search "$primary_pm" "$pkg"
            _search_xbps "$pkg"
            ;;
        zypper)
            announce_search "$primary_pm" "$pkg"
            _search_zypper "$pkg"
            ;;
        rpm-ostree)
            announce_search "$primary_pm" "$pkg"
            _search_rpm_ostree "$pkg"
            ;;
    esac
}

search_optionals() {
    local pkg="$1"
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
                    announce_search "$option" "$pkg"
                    _search_toolbox_pkg "$pkg"
                fi
                ;;
            flatpak)
                if [ "$flatpak_installed" -eq 1 ]; then
                    announce_search "$option" "$pkg"
                    _search_flatpak_pkg "$pkg"
                fi
                ;;
            snap)
                if [ "$snap_installed" -eq 1 ]; then
                    announce_search "$option" "$pkg"
                    _search_snap_pkg "$pkg"
                fi
                ;;
        esac
    done
}

search() {
    assert_arity "$#" "eq" 1 "<pkg>" || return 1

    local pkg="$1"
    detect_system

    case "$primary_pm" in
        rpm-ostree)
            search_optionals "$pkg"
            search_pm "$pkg"
            ;;
        *)
            if [ -n "$secondary_pm" ]; then
                search_sm "$pkg"
            else
                search_pm "$pkg"
            fi

            search_optionals "$pkg"
            ;;
    esac
}
