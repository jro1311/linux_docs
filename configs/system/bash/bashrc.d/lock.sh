# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

lock_apt() {
    local package="$1"
    detect_system

    if apt list "$package" 2>/dev/null | grep -Fq "$package"; then
        sudo apt-mark hold "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

lock_dnf() {
    local package="$1"
    detect_system

    if dnf list --available "$package" >/dev/null 2>&1; then
        sudo dnf versionlock add "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

lock_pacman() {
    local package="$1"
    detect_system

    if grep -q "^#IgnorePkg" /etc/pacman.conf; then
        sudo sed -i 's/^#IgnorePkg/IgnorePkg/' /etc/pacman.conf
    fi

    if ! grep -Fq "$package" /etc/pacman.conf; then
        sudo sed -i \
            "/^IgnorePkg[[:space:]]*=/ {
                s/[[:space:]]*$/ $package/
            }" \
            /etc/pacman.conf
    else
        no_package_found "$primary_pm" "$package"
    fi
}

lock_xbps() {
    local package="$1"
    detect_system

    if xbps-query -s "$package" | grep -Fq "$package"; then
        sudo xbps-pkgdb -m hold "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

lock_zypper() {
    local package="$1"
    detect_system

    if zypper se --match-exact "$package" >/dev/null 2>&1; then
        sudo zypper al "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

lock_toolbox_pkg() {
    local package="$1"

    if toolbox run dnf list --available "$package" >/dev/null 2>&1; then
        toolbox run sudo dnf versionlock add "$package"
    else
        no_package_found "dnf (toolbox)" "$package"
        return 1
    fi
}

lock_flatpak_pkg() {
    local package="$1"

    if flatpak list --app --columns=app | grep -Fq "$package"; then
        local full_package="app/$package"
        flatpak mask "$full_package"
    elif flatpak list --runtime --columns=app | grep -Fq "$package"; then
        local full_package="runtime/$package"
        flatpak mask "$full_package"
    else
        no_package_found "flatpak" "$package"
        return 1
    fi
}

lock_snap_pkg() {
    local package="$1"

    if snap list "$package" >/dev/null 2>&1; then
        confirm sudo snap refresh --hold "$package"
    else
        no_package_found "snap" "$package"
        return 1
    fi
}

lock_pm() {
    local package="$1"
    detect_system

    case "$primary_pm" in
        "apt")
            announce_lock "$primary_pm" "$package"
            lock_apt "$package"
            ;;
        "dnf")
            announce_lock "$primary_pm" "$package"
            lock_dnf "$package"
            ;;
        "eopkg")
            no_function_available
            ;;
        "pacman")
            announce_lock "$primary_pm" "$package"
            lock_pacman "$package"
            ;;
        "xbps")
            announce_lock "$primary_pm" "$package"
            lock_xbps "$package"
            ;;
        "zypper")
            announce_lock "$primary_pm" "$package"
            lock_zypper "$package"
            ;;
        "rpm-ostree")
            no_function_available
            ;;
    esac
}

lock_optionals() {
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
                    announce_lock "$option" "$package"
                    lock_toolbox_pkg "$package"
                fi
                ;;
            "flatpak")
                if [ "$flatpak_installed" -eq 1 ]; then
                    announce_lock "$option" "$package"
                    lock_flatpak_pkg "$package"
                fi
                ;;
            "snap")
                if [ "$snap_installed" -eq 1 ]; then
                    announce_lock "$option" "$package"
                    lock_snap_pkg "$package"
                fi
                ;;
        esac
    done
}

lock() {
    if [ "$#" -eq 0 ]; then
        red_message "lock:" "Expected at least 1 argument, got $#."
        return 1
    fi

    detect_system

    for package in "$@"; do
        case "$primary_pm" in
            "rpm-ostree")
                lock_optionals "$package"
                lock_pm "$package"
                ;;
            *)
                lock_pm "$package"
                lock_optionals "$package"
                ;;
        esac
    done
}
