# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

clean_apt() {
    detect_system
    case "$secondary_pm" in
        "nala")
            sudo nala autoremove && sudo nala clean
            ;;
        *)
            sudo apt autoremove && sudo apt clean
            ;;
    esac
}

clean_dnf() { sudo dnf autoremove && sudo dnf clean all; }

clean_eopkg() { sudo eopkg remove-orphans && sudo eopkg delete-cache && sudo eopkg clean; }

clean_pacman() {
    detect_system
    case "$secondary_pm" in
        "paru"|"yay")
            if "$secondary_pm" -Qdtq >/dev/null 2>&1; then
                "$secondary_pm" -Qdtq | sudo xargs -r "$secondary_pm" -Rns
            else
                echo "No packages to remove."
            fi
            ;;
        *)
            if pacman -Qdtq >/dev/null 2>&1; then
                pacman -Qdtq | sudo xargs -r pacman -Rns
            else
                echo "No packages to remove."
            fi
            ;;
    esac
}

clean_xbps() { sudo xbps-remove -Oo; }

clean_zypper() { sudo zypper purge-kernels && sudo zypper clean; }

clean_flatpak() { flatpak uninstall --unused; }

clean_rpm_ostree() { sudo rpm-ostree cleanup -bm; }

clean_toolbox() { toolbox run sudo dnf autoremove; }

clean() {
    detect_system
    local managers=(apt dnf eopkg pacman xbps zypper flatpak snap toolbox rpm-ostree)

    for manager in "${managers[@]}"; do
        local cleaning="${green}$manager:${reset} cleaning packages"
        local no_function_available="${yellow}$manager:${reset} no function available"

        case "$manager" in
            "apt")
                if [ "$primary_pm" = "apt" ]; then
                    echo "$cleaning"
                    clean_apt
                fi
                ;;
            "dnf")
                if [ "$primary_pm" = "dnf" ]; then
                    echo "$cleaning"
                    clean_dnf
                fi
                ;;
            "eopkg")
                if [ "$primary_pm" = "eopkg" ]; then
                    echo "$cleaning"
                    clean_eopkg
                fi
                ;;
            "pacman")
                if [ "$primary_pm" = "pacman" ]; then
                    echo "$cleaning"
                    clean_pacman
                fi
                ;;
            "xbps")
                if [ "$primary_pm" = "xbps" ]; then
                    echo "$cleaning"
                    clean_xbps
                fi
                ;;
            "zypper")
                if [ "$primary_pm" = "zypper" ]; then
                    echo "$cleaning"
                    clean_zypper
                fi
                ;;
            "flatpak")
                if [ "$flatpak_installed" -eq 1 ]; then
                    echo "$cleaning"
                    clean_flatpak
                fi
                ;;
            "snap")
                if [ "$snap_installed" -eq 1 ]; then
                    no_function_available
                fi
                ;;
            "toolbox")
                if [ "$toolbox_installed" -eq 1 ]; then
                    echo "$cleaning"
                    clean_toolbox
                fi
                ;;
            "rpm-ostree")
                if [ "$primary_pm" = "rpm-ostree" ]; then
                    echo "$cleaning"
                    clean_rpm_ostree
                fi
                ;;
        esac
    done
}
