search_apt() {
    local package="$1"
    case "$secondary_package_manager" in
        "nala")
            nala search "$package"
            ;;
        *)
            apt search "$package"
            ;;
    esac
}

search_dnf() {
    local package="$1"
    dnf search "$package"
}

search_eopkg() {
    local package="$1"
    eopkg search "$package"
}

search_pacman() {
    local package="$1"
    case "$secondary_package_manager" in
        "paru"|"yay")
            "$secondary_package_manager" -Ss "$package"
            ;;
        *)
            pacman -Ss "$package"
            ;;
    esac
}

search_xbps() {
    local package="$1"
    xbps-query -Rs "$package"
}

search_zypper() {
    local package="$1"
    zypper se "$package"
}

search_flatpak() {
    local package="$1"
    flatpak search "$package"
}

search_snap() {
    local package="$1"
    snap find "$package"
}

search_toolbox() {
    local package="$1"
    toolbox run dnf search "$package"
}

search_rpm_ostree() {
    local package="$1"
    rpm-ostree search "$package"
}

search() {
    local package="$1"
    if [ $# -eq 0 ]; then
        echo "Enter a package name."
        return 1
    fi

    local managers=(apt dnf eopkg pacman xbps zypper flatpak snap toolbox rpm-ostree)

    for manager in "${managers[@]}"; do
        local searching="${blue}Searching for '$package' using $manager... ${reset}"

        case "$manager" in
            "apt")
                if [ "$primary_package_manager" = "apt" ]; then
                    echo "$searching"
                    search_apt "$package"
                fi
                ;;
            "dnf")
                if [ "$primary_package_manager" = "dnf" ]; then
                    echo "$searching"
                    search_dnf "$package"
                fi
                ;;
            "eopkg")
                if [ "$primary_package_manager" = "eopkg" ]; then
                    echo "$searching"
                    search_eopkg "$package"
                fi
                ;;
            "pacman")
                if [ "$primary_package_manager" = "pacman" ]; then
                    echo "$searching"
                    search_pacman "$package"
                fi
                ;;
            "xbps")
                if [ "$primary_package_manager" = "xbps" ]; then
                    echo "$searching"
                    search_xbps "$package"
                fi
                ;;
            "zypper")
                if [ "$primary_package_manager" = "zypper" ]; then
                    echo "$searching"
                    search_zypper "$package"
                fi
                ;;
            "flatpak")
                if [ "$flatpak_installed" -eq 1 ]; then
                    echo "$searching"
                    search_flatpak "$package"
                fi
                ;;
            "snap")
                if [ "$snap_installed" -eq 1 ]; then
                    echo "$searching"
                    search_snap "$package"
                fi
                ;;
            "toolbox")
                if [ "$toolbox_installed" -eq 1 ]; then
                    echo "$searching"
                    search_toolbox "$package"
                fi
                ;;
            "rpm-ostree")
                if [ "$primary_package_manager" = "rpm-ostree" ]; then
                    echo "$searching"
                    search_rpm_ostree "$package"
                fi
                ;;
        esac
    done
}
