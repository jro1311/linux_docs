list_apt() {
    case "$secondary_package_manager" in
        "nala")
            nala list --installed
            ;;
        *)
            apt list --installed
            ;;
    esac
}

list_dnf() { dnf list --installed; }

list_eopkg() { eopkg list-installed; }

list_pacman() {
    case "$secondary_package_manager" in
        "paru"|"yay")
            "$secondary_package_manager" -Qs
            ;;
        *)
            pacman -Qs
            ;;
    esac
}

list_xbps() { xbps-query -sl; }

list_zypper() { zypper se -i; }

list_flatpak() { flatpak list; }

list_snap() { snap list; }

list_toolbox() { toolbox run dnf list --installed; }

list_rpm_ostree() { rpm -qa; }

list() {
    local managers=(apt dnf eopkg pacman xbps zypper flatpak snap toolbox rpm-ostree)

    for manager in "${managers[@]}"; do
        local listing="${blue}Listing installed packages using $manager... ${reset}"

        case "$manager" in
            "apt")
                if [ "$primary_package_manager" = "apt" ]; then
                    echo "$listing"
                    list_apt
                fi
                ;;
            "dnf")
                if [ "$primary_package_manager" = "dnf" ]; then
                    echo "$listing"
                    list_dnf
                fi
                ;;
            "eopkg")
                if [ "$primary_package_manager" = "eopkg" ]; then
                    echo "$listing"
                    list_eopkg
                fi
                ;;
            "pacman")
                if [ "$primary_package_manager" = "pacman" ]; then
                    echo "$listing"
                    list_pacman
                fi
                ;;
            "xbps")
                if [ "$primary_package_manager" = "xbps" ]; then
                    echo "$listing"
                    list_xbps
                fi
                ;;
            "zypper")
                if [ "$primary_package_manager" = "zypper" ]; then
                    echo "$listing"
                    list_zypper
                fi
                ;;
            "flatpak")
                if [ "$flatpak_installed" -eq 1 ]; then
                    echo "$listing"
                    list_flatpak
                fi
                ;;
            "snap")
                if [ "$snap_installed" -eq 1 ]; then
                    echo "$listing"
                    list_snap
                fi
                ;;
            "toolbox")
                if [ "$toolbox_installed" -eq 1 ]; then
                    echo "$listing"
                    list_toolbox
                fi
                ;;
            "rpm-ostree")
                if [ "$primary_package_manager" = "rpm-ostree" ]; then
                    echo "$listing"
                    list_rpm_ostree
                fi
                ;;
        esac
    done
}
