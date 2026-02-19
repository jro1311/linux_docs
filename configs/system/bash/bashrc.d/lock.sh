lock_apt() {
    local package="$1"
    local locking="$2"
    if apt list "$package" 2>/dev/null | grep -Fiq "$package"; then
        echo "$locking"
        sudo apt-mark hold "$package"
    else
        no_package_found "$secondary_package_manager" "$package"
    fi
}

lock_dnf() {
    local package="$1"
    local locking="$2"
    if dnf list --available "$package" >/dev/null 2>&1; then
        echo "$locking"
        sudo dnf versionlock add "$package"
    else
        no_package_found "$primary_package_manager" "$package"
    fi
}

lock_pacman() {
    local package="$1"
    local locking="$2"
    if grep -q "^#IgnorePkg" /etc/pacman.conf; then
        sudo sed -i 's/^#IgnorePkg/IgnorePkg/' /etc/pacman.conf
    fi

    if ! grep -Fq "$package" /etc/pacman.conf; then
        echo "$locking"
        sudo sed -i "/^IgnorePkg[[:space:]]*=/s/[[:space:]]*$/ $package/" /etc/pacman.conf
    else
        no_package_found "$primary_package_manager" "$package"
    fi
}

lock_xbps() {
    local package="$1"
    local locking="$2"
    if xbps-query -s "$package" | grep -Fiq "$package"; then
        echo "$locking"
        sudo xbps-pkgdb -m hold "$package"
    else
        no_package_found "$primary_package_manager" "$package"
    fi
}

lock_zypper() {
    local package="$1"
    local locking="$2"
    if zypper se --match-exact "$package" >/dev/null 2>&1; then
        echo "$locking"
        sudo zypper al "$package"
    else
        no_package_found "$primary_package_manager" "$package"
    fi
}

lock_flatpak_pkg() {
    local package="$1"
    local locking="$2"
    if flatpak list --app --columns=app | grep -q "^$package"; then
        echo "$locking"
        local full_package="app/$package"
        flatpak mask "$full_package"
    elif flatpak list --runtime --columns=app | grep -q "^$package"; then
        echo "$locking"
        local full_package="runtime/$package"
        flatpak mask "$full_package"
    else
        no_package_found "flatpak" "$package"
        return 1
    fi
}

lock_snap_pkg() {
    local package="$1"
    local locking="$2"
    if snap list | awk '{print $1}' | grep -iq "^$package"; then
        echo "$locking"
        confirm sudo snap refresh --hold "$package"
    else
        no_package_found "snap" "$package"
        return 1
    fi
}

lock_toolbox_pkg() {
    local package="$1"
    local locking="$2"
    if toolbox run dnf list --available "$package" >/dev/null 2>&1; then
        echo "$locking"
        toolbox run sudo dnf versionlock add "$package"
    else
        no_package_found "dnf (toolbox)" "$package"
        return 1
    fi
}

lock() {
    if [ $# -eq 0 ]; then
        echo "Enter a package name."
        return 1
    fi

    local managers=(apt dnf eopkg pacman xbps zypper flatpak snap toolbox rpm-ostree)

    for package in "$@"; do
        for manager in "${managers[@]}"; do
            local locking="${green}Locking '$package' using $manager... ${reset}"
            local no_function_available="${yellow}Function not available using $manager. ${reset}"

            case "$manager" in
                "apt")
                    if [ "$primary_package_manager" = "apt" ]; then
                        lock_apt "$package" "$locking"
                    fi
                    ;;
                "dnf")
                    if [ "$primary_package_manager" = "dnf" ]; then
                        lock_dnf "$package" "$locking"
                    fi
                    ;;
                "eopkg")
                    if [ "$primary_package_manager" = "eopkg" ]; then
                        no_function_available
                    fi
                    ;;
                "pacman")
                    if [ "$primary_package_manager" = "pacman" ]; then
                        lock_pacman "$package" "$locking"
                    fi
                    ;;
                "xbps")
                    if [ "$primary_package_manager" = "xbps" ]; then
                        lock_xbps "$package" "$locking"
                    fi
                    ;;
                "zypper")
                    if [ "$primary_package_manager" = "zypper" ]; then
                        lock_zypper "$package" "$locking"
                    fi
                    ;;
                "flatpak")
                    if [ "$flatpak_installed" -eq 1 ]; then
                        lock_flatpak_pkg "$package" "$locking"
                    fi
                    ;;
                "snap")
                    if [ "$snap_installed" -eq 1 ]; then
                        lock_snap_pkg "$package" "$locking"
                    fi
                    ;;
                "toolbox")
                    if [ "$toolbox_installed" -eq 1 ]; then
                        lock_toolbox_pkg "$package" "$locking"
                    fi
                    ;;
                "rpm-ostree")
                    if [ "$primary_package_manager" = "rpm-ostree" ]; then
                        no_function_available
                    fi
                    ;;
            esac
        done
    done
}
