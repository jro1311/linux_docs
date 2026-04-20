# shellcheck shell=bash
# shellcheck source=/dev/null
# shellcheck disable=SC2034,SC2154

remove_nala() {
    local package="$1"
    detect_system

    if apt list --installed "$package" 2>/dev/null | grep -Fq "$package"; then
        case "$package" in
            "nala")
                sudo apt remove "$package"
                ;;
            *)
                sudo nala remove "$package"
                ;;
        esac
    else
        no_package_found "$secondary_pm" "$package"
    fi
}

remove_apt() {
    local package="$1"
    detect_system

    if apt list --installed "$package" 2>/dev/null | grep -Fq "$package"; then
        sudo apt remove "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

remove_dnf() {
    local package="$1"
    detect_system

    if dnf list --installed "$package" >/dev/null 2>&1; then
        sudo dnf remove "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

remove_eopkg() {
    local package="$1"
    detect_system

    if eopkg search -i --name "^$package" 2>/dev/null | grep -Fq "$package"; then
        sudo eopkg remove "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

remove_aur_helper() {
    local package="$1"
    detect_system

    if "$secondary_pm" -Qs "^$package$" >/dev/null 2>&1; then
        "$secondary_pm" -Rs "$package"
    else
        no_package_found "$secondary_pm" "$package"
    fi
}

remove_pacman() {
    local package="$1"
    detect_system

    if pacman -Qs "^$package$" >/dev/null 2>&1; then
        sudo pacman -Rs "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

remove_xbps() {
    local package="$1"
    detect_system

    if xbps-query -s "$package" | grep -Fiq "$package"; then
        sudo xbps-remove -R "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

remove_zypper() {
    local package="$1"
    detect_system

    if zypper se -i --match-exact "$package" >/dev/null 2>&1; then
        sudo zypper rm --clean-deps "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

remove_rpm_ostree() {
    local package="$1"
    detect_system

    if rpm -qa | grep -q "^$package"; then
        confirm sudo rpm-ostree remove "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

remove_toolbox_pkg() {
    local package="$1"

    if toolbox run dnf list --installed "$package" >/dev/null 2>&1; then
        toolbox run sudo dnf remove "$package"
    else
        no_package_found "dnf (toolbox)" "$package"
        return 1
    fi
}

remove_flatpak_pkg() {
    local package="$1"

    if flatpak list --columns=name,application | grep -Fiq "$package"; then
        flatpak remove "$package"
    else
        no_package_found "flatpak" "$package"
        return 1
    fi
}

remove_snap_pkg() {
    local package="$1"

    if snap list "$package" >/dev/null 2>&1; then
        confirm sudo snap remove "$package"
    else
        no_package_found "snap" "$package"
        return 1
    fi
}

remove_sm() {
    local package="$1"
    detect_system

    case "$secondary_pm" in
        "nala")
            announce_remove "$secondary_pm" "$package"
            remove_nala "$package"
            ;;
        "paru"|"yay")
            announce_remove "$secondary_pm" "$package"
            remove_aur_helper "$package"
            ;;
    esac
}

remove_pm() {
    local package="$1"
    detect_system

    case "$primary_pm" in
        "apt")
            announce_remove "$primary_pm" "$package"
            remove_apt "$package"
            ;;
        "dnf")
            announce_remove "$primary_pm" "$package"
            remove_dnf "$package"
            ;;
        "eopkg")
            announce_remove "$primary_pm" "$package"
            remove_eopkg "$package"
            ;;
        "pacman")
            announce_remove "$primary_pm" "$package"
            remove_pacman "$package"
            ;;
        "xbps")
            announce_remove "$primary_pm" "$package"
            remove_xbps "$package"
            ;;
        "zypper")
            announce_remove "$primary_pm" "$package"
            remove_zypper "$package"
            ;;
        "rpm-ostree")
            announce_remove "$primary_pm" "$package"
            remove_rpm_ostree "$package"
            ;;
    esac
}

remove_optionals() {
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
                    announce_remove "$option" "$package"
                    remove_toolbox_pkg "$package"
                fi
                ;;
            "flatpak")
                if [ "$flatpak_installed" -eq 1 ]; then
                    announce_remove "$option" "$package"
                    remove_flatpak_pkg "$package"
                fi
                ;;
            "snap")
                if [ "$snap_installed" -eq 1 ]; then
                    announce_remove "$option" "$package"
                    remove_snap_pkg "$package"
                fi
                ;;
        esac
    done
}

remove() {
    if [ "$#" -eq 0 ]; then
        red_message "remove:" "Expected at least 1 argument, got $#."
        return 1
    fi

    detect_system

    for package in "$@"; do
        case "$primary_pm" in
            "rpm-ostree")
                remove_optionals "$package"
                remove_pm "$package"
                ;;
            *)
                if [ -n "$secondary_pm" ]; then
                    remove_sm "$package"
                else
                    remove_pm "$package"
                fi

                remove_optionals "$package"
                ;;
        esac

        case "$package" in
            "flatpak"|"snap"|"toolbox")
                detect_optionals
                ;;
            "nala")
                detect_secondary_pm
                ;;
        esac
    done
}
