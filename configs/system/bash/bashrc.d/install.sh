# shellcheck shell=bash
# shellcheck source=/dev/null
# shellcheck disable=SC2034,SC2154

install_nala() {
    local package="$1"
    detect_system

    if apt list "$package" 2>/dev/null | grep -Fq "$package"; then
        sudo nala install "$package"
    else
        no_package_found "$secondary_pm" "$package"
    fi
}

install_apt() {
    local package="$1"
    detect_system

    if apt list "$package" 2>/dev/null | grep -Fq "$package"; then
        sudo apt install "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

install_dnf() {
    local package="$1"
    detect_system

    if dnf list --available "$package" >/dev/null 2>&1; then
        sudo dnf install "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

install_eopkg() {
    local package="$1"
    detect_system

    if eopkg search --name "^$package" | grep -Fq "$package"; then
        sudo eopkg install "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

install_aur_helper() {
    local package="$1"
    detect_system

    if "$secondary_pm" -Ss "^$package$" >/dev/null 2>&1; then
        "$secondary_pm" -S --needed "$package"
    else
        no_package_found "$secondary_pm" "$package"
    fi
}

install_pacman() {
    local package="$1"
    detect_system

    if pacman -Ss "^$package$" >/dev/null 2>&1; then
        sudo pacman -S --needed "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

install_xbps() {
    local package="$1"
    detect_system

    if xbps-query -Rs "$package" | grep -Fq "$package"; then
        sudo xbps-install -S "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

install_zypper() {
    local package="$1"
    detect_system

    if zypper se --match-exact "$package" >/dev/null 2>&1; then
        sudo zypper in "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

install_rpm_ostree() {
    local package="$1"
    detect_system

    if rpm-ostree search "$package" | awk 'NR > 2 {print $1}' | grep -q "^$package"; then
        confirm sudo rpm-ostree install "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

install_flatpak_pkg() {
    local package="$1"

    if flatpak search --columns=name,application "$package" | grep -Fiq "$package"; then
        flatpak install "$package"
    else
        no_package_found "flatpak" "$package"
        return 1
    fi
}

install_snap_pkg() {
    local package="$1"

    if snap find "$package" 2>/dev/null | awk '{print $1}' | grep -Fq "$package"; then
        confirm sudo snap install "$package"
    else
        no_package_found "snap" "$package"
        return 1
    fi
}

install_toolbox_pkg() {
    local package="$1"

    if toolbox run dnf list --available "$package" >/dev/null 2>&1; then
        toolbox run sudo dnf install "$package"
    else
        no_package_found "dnf (toolbox)" "$package"
        return 1
    fi
}

install_sm() {
    local package="$1"
    detect_system

    case "$secondary_pm" in
        "nala")
            announce_remove "$secondary_pm" "$package"
            install_nala "$package"
            ;;
        "paru"|"yay")
            announce_remove "$secondary_pm" "$package"
            install_aur_helper "$package"
            ;;
    esac
}

install_pm() {
    local package="$1"
    detect_system

    case "$primary_pm" in
        "apt")
            announce_install "$primary_pm" "$package"
            install_apt "$package"
            ;;
        "dnf")
            announce_install "$primary_pm" "$package"
            install_dnf "$package"
            ;;
        "eopkg")
            announce_install "$primary_pm" "$package"
            install_eopkg "$package"
            ;;
        "pacman")
            announce_install "$primary_pm" "$package"
            install_pacman "$package"
            ;;
        "xbps")
            announce_install "$primary_pm" "$package"
            install_xbps "$package"
            ;;
        "zypper")
            announce_install "$primary_pm" "$package"
            install_zypper "$package"
            ;;
        "rpm-ostree")
            announce_install "$primary_pm" "$package"
            install_rpm_ostree "$package"
            ;;
    esac
}

install_optionals() {
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
                    announce_install "$option" "$package"
                    install_flatpak_pkg "$package"
                fi
                ;;
            "snap")
                if [ "$snap_installed" -eq 1 ]; then
                    announce_install "$option" "$package"
                    install_snap_pkg "$package"
                fi
                ;;
            "toolbox")
                if [ "$toolbox_installed" -eq 1 ]; then
                    announce_install "$option" "$package"
                    install_toolbox_pkg "$package"
                fi
                ;;
        esac
    done
}

install() {
    if [ "$#" -eq 0 ]; then
        red_message "install:" "Expected at least 1 argument, got $#."
        return 1
    fi

    detect_system

    for package in "$@"; do
        if [ -n "$secondary_pm" ]; then
            install_sm "$package"
        else
            install_pm "$package"
        fi

        install_optionals "$package"

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
