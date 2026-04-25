# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_search_nala() {
    local package="$1"
    nala search "$package"
}

_search_apt() {
    local package="$1"
    apt search "$package"
}

_search_dnf() {
    local package="$1"
    dnf search "$package"
}

_search_eopkg() {
    local package="$1"
    eopkg search "$package"
}

_search_aur_pkg() {
    local package="$1"
    "$secondary_pm" -Ss "$package"
}

_search_pacman() {
    local package="$1"
    pacman -Ss "$package"
}

_search_xbps() {
    local package="$1"
    xbps-query -Rs "$package"
}

_search_zypper() {
    local package="$1"
    zypper se "$package"
}

_search_rpm_ostree() {
    local package="$1"
    rpm-ostree search "$package"
}

_search_toolbox_pkg() {
    local package="$1"
    toolbox run dnf search "$package"
}

_search_flatpak_pkg() {
    local package="$1"
    flatpak search "$package"
}

_search_snap_pkg() {
    local package="$1"
    snap find "$package"
}

search_sm() {
    local package="$1"

    case "$secondary_pm" in
        "nala")
            announce_list "$secondary_pm"
            _search_nala "$package"
            ;;
        paru|yay)
            announce_list "$secondary_pm"
            _search_aur_pkg "$package"
            ;;
    esac
}

search_pm() {
    local package="$1"

    case "$primary_pm" in
        apt)
            announce_search "$primary_pm" "$package"
            _search_apt "$package"
            ;;
        dnf)
            announce_search "$primary_pm" "$package"
            _search_dnf "$package"
            ;;
        eopkg)
            announce_search "$primary_pm" "$package"
            _search_eopkg "$package"
            ;;
        pacman)
            announce_search "$primary_pm" "$package"
            _search_pacman "$package"
            ;;
        xbps)
            announce_search "$primary_pm" "$package"
            _search_xbps "$package"
            ;;
        zypper)
            announce_search "$primary_pm" "$package"
            _search_zypper "$package"
            ;;
        rpm-ostree)
            announce_search "$primary_pm" "$package"
            _search_rpm_ostree "$package"
            ;;
    esac
}

search_optionals() {
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
                    _search_toolbox_pkg "$package"
                fi
                ;;
            flatpak)
                if [ "$flatpak_installed" -eq 1 ]; then
                    announce_search "$option" "$package"
                    _search_flatpak_pkg "$package"
                fi
                ;;
            snap)
                if [ "$snap_installed" -eq 1 ]; then
                    announce_search "$option" "$package"
                    _search_snap_pkg "$package"
                fi
                ;;
        esac
    done
}

search() {
    assert_arity "$#" "eq" 1 "<package>" || return 1

    local package="$1"
    detect_system

    case "$primary_pm" in
        rpm-ostree)
            search_optionals "$package"
            search_pm "$package"
            ;;
        *)
            if [ -n "$secondary_pm" ]; then
                search_sm "$package"
            else
                search_pm "$package"
            fi

            search_optionals "$package"
            ;;
    esac
}
