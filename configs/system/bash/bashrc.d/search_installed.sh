# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

search_installed_nala() {
    local package="$1"
    nala list --installed "$package"
}

search_installed_apt() {
    local package="$1"
    apt list --installed "$package"
}

search_installed_dnf() {
    local package="$1"
    dnf list --installed "$package"
}

search_installed_eopkg() {
    local package="$1"
    eopkg search -i "$package"
}

search_installed_aur_helper_pkg() {
    local package="$1"
    detect_system
    "$secondary_pm" -Qs "$package"
}

search_installed_pacman() {
    local package="$1"
    pacman -Qs "$package"
}

search_installed_xbps() {
    local package="$1"
    xbps-query -s "$package"
}

search_installed_zypper() {
    local package="$1"
    zypper se -i "$package"
}

search_installed_rpm_ostree() {
    local package="$1"
    rpm -qa | grep -i "^$package"
}

search_installed_toolbox_pkg() {
    local package="$1"
    toolbox run dnf list --installed "$package"
}

search_installed_flatpak_pkg() {
    local package="$1"
    flatpak list | grep -Fi "$package"
}

search_installed_snap_pkg() {
    local package="$1"
    snap list "$package"
}

search_installed_sm() {
    local package="$1"
    detect_system

    case "$secondary_pm" in
        "nala")
            announce_list "$secondary_pm"
            search_installed_nala "$package"
            ;;
        "paru"|"yay")
            announce_list "$secondary_pm"
            search_installed_aur_helper_pkg "$package"
            ;;
    esac
}

search_installed_pm() {
    local package="$1"
    detect_system

    case "$primary_pm" in
        "apt")
            announce_search "$primary_pm" "$package"
            search_installed_apt "$package"
            ;;
        "dnf")
            announce_search "$primary_pm" "$package"
            search_installed_dnf "$package"
            ;;
        "eopkg")
            announce_search "$primary_pm" "$package"
            search_installed_eopkg "$package"
            ;;
        "pacman")
            announce_search "$primary_pm" "$package"
            search_installed_pacman "$package"
            ;;
        "xbps")
            announce_search "$primary_pm" "$package"
            search_installed_xbps "$package"
            ;;
        "zypper")
            announce_search "$primary_pm" "$package"
            search_installed_zypper "$package"
            ;;
        "rpm-ostree")
            announce_search "$primary_pm" "$package"
            search_installed_rpm_ostree "$package"
            ;;
    esac
}

search_installed_optionals() {
    local package="$1"
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
                    announce_search "$option" "$package"
                    search_installed_toolbox_pkg "$package"
                fi
                ;;
            "flatpak")
                if [ "$flatpak_installed" -eq 1 ]; then
                    announce_search "$option" "$package"
                    search_installed_flatpak_pkg "$package"
                fi
                ;;
            "snap")
                if [ "$snap_installed" -eq 1 ]; then
                    announce_search "$option" "$package"
                    search_installed_snap_pkg "$package"
                fi
                ;;
        esac
    done
}

search_installed() {
    if [ "$#" -ne 1 ]; then
        red_message "search_installed:" "Expected 1 argument, got $#."
        return 1
    fi

    local package="$1"
    detect_system

    case "$primary_pm" in
        "rpm-ostree")
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
