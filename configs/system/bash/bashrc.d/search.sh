# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

search_nala() {
    local package="$1"
    nala search "$package"
}

search_apt() {
    local package="$1"
    apt search "$package"
}

search_dnf() {
    local package="$1"
    dnf search "$package"
}

search_eopkg() {
    local package="$1"
    eopkg search "$package"
}

search_aur_helper() {
    detect_system
    "$secondary_pm" -Ss "$package"
}

search_pacman() { pacman -Ss "$package"; }

search_xbps() {
    local package="$1"
    xbps-query -Rs "$package"
}

search_zypper() {
    local package="$1"
    zypper se "$package"
}

search_rpm_ostree() {
    local package="$1"
    rpm-ostree search "$package"
}

search_flatpak_pkg() {
    local package="$1"
    flatpak search "$package"
}

search_snap_pkg() {
    local package="$1"
    snap find "$package"
}

search_toolbox_pkg() {
    local package="$1"
    toolbox run dnf search "$package"
}

search_sm() {
    local package="$1"
    detect_system

    case "$secondary_pm" in
        "nala")
            announce_list "$secondary_pm"
            search_nala "$package"
            ;;
        "paru"|"yay")
            announce_list "$secondary_pm"
            search_aur_helper "$package"
            ;;
    esac
}

search_pm() {
    local package="$1"
    detect_system

    case "$primary_pm" in
        "apt")
            announce_search "$primary_pm" "$package"
            search_apt "$package"
            ;;
        "dnf")
            announce_search "$primary_pm" "$package"
            search_dnf "$package"
            ;;
        "eopkg")
            announce_search "$primary_pm" "$package"
            search_eopkg "$package"
            ;;
        "pacman")
            announce_search "$primary_pm" "$package"
            search_pacman "$package"
            ;;
        "xbps")
            announce_search "$primary_pm" "$package"
            search_xbps "$package"
            ;;
        "zypper")
            announce_search "$primary_pm" "$package"
            search_zypper "$package"
            ;;
        "rpm-ostree")
            announce_search "$primary_pm" "$package"
            search_rpm_ostree "$package"
            ;;
    esac
}

search_optionals() {
    local package="$1"
    detect_system

    optionals=(
        "flatpak"
        "snap"
        "toolbox"
    )

    for option in "${optionals[@]}"; do
        case "$option" in
            "flatpak")
                if [ "$flatpak_installed" -eq 1 ]; then
                    announce_search "$option" "$package"
                    search_flatpak_pkg "$package"
                fi
                ;;
            "snap")
                if [ "$snap_installed" -eq 1 ]; then
                    announce_search "$option" "$package"
                    search_snap_pkg "$package"
                fi
                ;;
            "toolbox")
                if [ "$toolbox_installed" -eq 1 ]; then
                    announce_search "$option" "$package"
                    search_toolbox_pkg "$package"
                fi
                ;;
        esac
    done
}

search() {
    if [ "$#" -ne 1 ]; then
        red_message "search:" "Expected 1 argument, got $#."
        return 1
    fi

    local package="$1"
    detect_system

    case "$primary_pm" in
        "rpm-ostree")
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
