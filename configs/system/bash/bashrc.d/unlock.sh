# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

unlock_apt() {
    local package="$1"
    detect_system

    if apt list "$package" 2>/dev/null | grep -Fq "$package"; then
        sudo apt-mark unhold "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

unlock_dnf() {
    local package="$1"
    detect_system

    if dnf list --available "$package" >/dev/null 2>&1; then
        sudo dnf versionlock delete "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

unlock_pacman() {
    local package="$1"
    detect_system

    if grep -q "^#IgnorePkg" /etc/pacman.conf; then
        sudo sed -i 's/^#IgnorePkg/IgnorePkg/' /etc/pacman.conf
    fi

    if grep -Fq "$package" /etc/pacman.conf; then
        sudo sed -i \
            "/^IgnorePkg/ {
                s/\([[:space:]]\+\)${package}[[:space:]]\+/\1/g
                s/^${package}[[:space:]]\+//
                s/[[:space:]]\+$//
            }" \
            /etc/pacman.conf
    else
        no_package_found "$primary_pm" "$package"
    fi
}

unlock_xbps() {
    local package="$1"
    detect_system

    if xbps-query -s "$package" | grep -Fq "$package"; then
        sudo xbps-pkgdb -m unhold "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

unlock_zypper() {
    local package="$1"
    detect_system

    if zypper se --match-exact "$package" >/dev/null 2>&1; then
        sudo zypper rl "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

unlock_toolbox_pkg() {
    local package="$1"

    if toolbox run dnf list --available "$package" >/dev/null 2>&1; then
        toolbox run sudo dnf versionlock delete "$package"
    else
        no_package_found "dnf (toolbox)" "$package"
        return 1
    fi
}

unlock_flatpak_pkg() {
    local package="$1"

    if flatpak list --app --columns=app | grep -Fq "$package"; then
        flatpak mask --remove "app/$package"
    elif flatpak list --runtime --columns=app | grep -Fq "$package"; then
        flatpak mask --remove "runtime/$package"
    else
        no_package_found "flatpak" "$package"
        return 1
    fi
}

unlock_snap_pkg() {
    local package="$1"

    if snap list "$package" >/dev/null 2>&1; then
        confirm sudo snap refresh --unhold "$package"
    else
        no_package_found "snap" "$package"
        return 1
    fi
}

unlock_pm() {
    local package="$1"
    detect_system

    case "$primary_pm" in
        "apt")
            announce_unlock "$primary_pm" "$package"
            unlock_apt "$package"
            ;;
        "dnf")
            announce_unlock "$primary_pm" "$package"
            unlock_dnf "$package"
            ;;
        "eopkg")
            no_function_available "$primary_pm"
            ;;
        "pacman")
            announce_unlock "$primary_pm" "$package"
            unlock_pacman "$package"
            ;;
        "xbps")
            announce_unlock "$primary_pm" "$package"
            unlock_xbps "$package"
            ;;
        "zypper")
            announce_unlock "$primary_pm" "$package"
            unlock_zypper "$package"
            ;;
        "rpm-ostree")
            no_function_available "$primary_pm"
            ;;
    esac
}

unlock_optionals() {
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
                    announce_unlock "$option" "$package"
                    unlock_toolbox_pkg "$package"
                fi
                ;;
            "flatpak")
                if [ "$flatpak_installed" -eq 1 ]; then
                    announce_unlock "$option" "$package"
                    unlock_flatpak_pkg "$package"
                fi
                ;;
            "snap")
                if [ "$snap_installed" -eq 1 ]; then
                    announce_unlock "$option" "$package"
                    unlock_snap_pkg "$package"
                fi
                ;;
        esac
    done
}

unlock() {
    if [ "$#" -eq 0 ]; then
        red_message "unlock:" "Expected at least 1 argument, got $#."
        return 1
    fi

    detect_system

    for package in "$@"; do
        case "$primary_pm" in
            "rpm-ostree")
                unlock_optionals "$package"
                unlock_pm "$package"
                ;;
            *)
                unlock_pm "$package"
                unlock_optionals "$package"
                ;;
        esac
    done
}
