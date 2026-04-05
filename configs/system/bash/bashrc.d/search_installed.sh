# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

search_installed_apt() {
    detect_system
    local package="$1"
    case "$secondary_package_manager" in
        "nala")
            nala list --installed "$package"
            ;;
        *)
            apt list --installed "$package"
            ;;
    esac
}

search_installed_dnf() {
    local package="$1"
    dnf list --installed "$package"
}

search_installed_eopkg() {
    local package="$1"
    eopkg search -i "$package"
}

search_installed_pacman() {
    detect_system
    local package="$1"
    case "$secondary_package_manager" in
        "paru"|"yay")
            "$secondary_package_manager" -Qs "$package"
            ;;
        *)
            pacman -Qs "$package"
            ;;
    esac
}

search_installed_xbps() {
    local package="$1"
    xbps-query -s "$package"
}

search_installed_zypper() {
    local package="$1"
    zypper se -i "$package"
}

search_installed_flatpak() {
    local package="$1"
    flatpak list | grep -Fi "$package"
}

search_installed_snap() {
    local package="$1"
    snap list "$package"
}

search_installed_toolbox() {
    local package="$1"
    toolbox run dnf list --installed "$package"
}

search_installed_rpm_ostree() {
    local package="$1"
    rpm -qa | grep -i "^$package"
}

search_installed() {
    local package="$1"
    if [ $# -eq 0 ]; then
        echo "Enter a package name."
        return 1
    fi

    detect_system
    local managers=(apt dnf eopkg pacman xbps zypper flatpak snap toolbox rpm-ostree)

    for manager in "${managers[@]}"; do
        local searching="${blue}Searching for '$package' using $manager... ${reset}"

        case "$manager" in
            "apt")
                if [ "$primary_package_manager" = "apt" ]; then
                    echo "$searching"
                    search_installed_apt "$package"
                fi
                ;;
            "dnf")
                if [ "$primary_package_manager" = "dnf" ]; then
                    echo "$searching"
                    search_installed_dnf "$package"
                fi
                ;;
            "eopkg")
                if [ "$primary_package_manager" = "eopkg" ]; then
                    echo "$searching"
                    search_installed_eopkg "$package"
                fi
                ;;
            "pacman")
                if [ "$primary_package_manager" = "pacman" ]; then
                    echo "$searching"
                    search_installed_pacman "$package"
                fi
                ;;
            "xbps")
                if [ "$primary_package_manager" = "xbps" ]; then
                    echo "$searching"
                    search_installed_xbps "$package"
                fi
                ;;
            "zypper")
                if [ "$primary_package_manager" = "zypper" ]; then
                    echo "$searching"
                    search_installed_zypper "$package"
                fi
                ;;
            "flatpak")
                if [ "$flatpak_installed" -eq 1 ]; then
                    echo "$searching"
                    search_installed_flatpak "$package"
                fi
                ;;
            "snap")
                if [ "$snap_installed" -eq 1 ]; then
                    echo "$searching"
                    search_installed_snap "$package"
                fi
                ;;
            "toolbox")
                if [ "$toolbox_installed" -eq 1 ]; then
                    echo "$searching"
                    search_installed_toolbox "$package"
                fi
                ;;
            "rpm-ostree")
                if [ "$primary_package_manager" = "rpm-ostree" ]; then
                    echo "$searching"
                    search_installed_rpm_ostree "$package"
                fi
                ;;
        esac
    done
}
