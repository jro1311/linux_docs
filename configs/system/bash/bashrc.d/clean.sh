# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

clean_nala() { sudo nala autoremove && sudo nala clean; }

clean_apt() { sudo apt autoremove && sudo apt clean; }

clean_dnf() { sudo dnf autoremove && sudo dnf clean all; }

clean_eopkg() { sudo eopkg remove-orphans && sudo eopkg delete-cache && sudo eopkg clean; }

clean_aur_helper() {
    detect_system
    if "$secondary_pm" -Qdtq >/dev/null 2>&1; then
        "$secondary_pm" -Qdtq | sudo xargs -r "$secondary_pm" -Rns
    else
        echo "No packages to remove."
    fi
}

clean_pacman() {
    if pacman -Qdtq >/dev/null 2>&1; then
        pacman -Qdtq | sudo xargs -r pacman -Rns
    else
        echo "No packages to remove."
    fi
}

clean_xbps() { sudo xbps-remove -Oo; }

clean_zypper() { sudo zypper purge-kernels && sudo zypper clean; }

clean_rpm_ostree() { sudo rpm-ostree cleanup -bm; }

clean_flatpak() { flatpak uninstall --unused; }

clean_toolbox() { toolbox run sudo dnf autoremove; }

clean_sm() {
    detect_system
    case "$secondary_pm" in
        "nala")
            announce_clean "$secondary_pm"
            clean_nala "$package"
            ;;
        "paru"|"yay")
            announce_clean "$secondary_pm"
            clean_aur_helper "$package"
            ;;
    esac
}

clean_pm() {
    detect_system
    case "$primary_pm" in
        "apt")
            announce_clean "$primary_pm"
            clean_apt
            ;;
        "dnf")
            announce_clean "$primary_pm"
            clean_dnf
            ;;
        "eopkg")
            announce_clean "$primary_pm"
            clean_eopkg
            ;;
        "pacman")
            announce_clean "$primary_pm"
            clean_pacman
            ;;
        "xbps")
            announce_clean "$primary_pm"
            clean_xbps
            ;;
        "zypper")
            announce_clean "$primary_pm"
            clean_zypper
            ;;
        "rpm-ostree")
            announce_clean "$primary_pm"
            clean_rpm_ostree
            ;;
    esac
}

clean_optionals() {
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
                    announce_clean "$option"
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
                    announce_clean "$option"
                    clean_toolbox
                fi
                ;;
        esac
    done
}

clean() {
    detect_system
    case "$primary_pm" in
        "rpm-ostree")
            clean_optionals
            clean_pm
            ;;
        *)
            if [ -n "$secondary_pm" ]; then
                clean_sm
            else
                clean_pm
            fi

            clean_optionals
            ;;
    esac
}
