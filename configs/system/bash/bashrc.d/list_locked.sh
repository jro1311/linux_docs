list_locked_apt() { apt-mark showhold; }

list_locked_dnf() { dnf versionlock list; }

list_locked_pacman() { grep -Fi "IgnorePkg" /etc/pacman.conf; }

list_locked_xbps() { xbps-query -H; }

list_locked_zypper() { zypper ll; }

list_locked_flatpak_pkg() { flatpak mask; }

list_locked_snap_pkg() { snap list | grep -Fi "held"; }

list_locked_toolbox_pkg() { toolbox run sudo dnf versionlock list; }

list_locked() {
    detect_system
    local managers=(apt dnf eopkg pacman xbps zypper flatpak snap toolbox rpm-ostree)

    for manager in "${managers[@]}"; do
        local listing_locked="${green}Listing locked packages using $manager... ${reset}"
        local no_function_available="${yellow}Function not available using $manager. ${reset}"

        case "$manager" in
            "apt")
                if [ "$primary_package_manager" = "apt" ]; then
                    echo "$listing_locked"
                    list_locked_apt
                fi
                ;;
            "dnf")
                if [ "$primary_package_manager" = "dnf" ]; then
                    echo "$listing_locked"
                    list_locked_dnf
                fi
                ;;
            "eopkg")
                if [ "$primary_package_manager" = "eopkg" ]; then
                    no_function_available
                fi
                ;;
            "pacman")
                if [ "$primary_package_manager" = "pacman" ]; then
                    echo "$listing_locked"
                    list_locked_pacman
                fi
                ;;
            "xbps")
                if [ "$primary_package_manager" = "xbps" ]; then
                    echo "$listing_locked"
                    list_locked_xbps
                fi
                ;;
            "zypper")
                if [ "$primary_package_manager" = "zypper" ]; then
                    echo "$listing_locked"
                    list_locked_zypper
                fi
                ;;
            "flatpak")
                if [ "$flatpak_installed" -eq 1 ]; then
                    echo "$listing_locked"
                    list_locked_flatpak_pkg
                fi
                ;;
            "snap")
                if [ "$snap_installed" -eq 1 ]; then
                    echo "$listing_locked"
                    list_locked_snap_pkg
                fi
                ;;
            "toolbox")
                if [ "$toolbox_installed" -eq 1 ]; then
                    echo "$listing_locked"
                    list_locked_toolbox_pkg
                fi
                ;;
            "rpm-ostree")
                if [ "$primary_package_manager" = "rpm-ostree" ]; then
                    no_function_available
                fi
                ;;
        esac
    done
}
