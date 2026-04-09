# shellcheck shell=bash
# shellcheck source=/dev/null
# shellcheck disable=SC2034,SC2154

remove_apt() {
    detect_system
    local package="$1"
    local removing="$2"
    case "$secondary_pm" in
        "nala")
            if apt list --installed "$package" 2>/dev/null | grep -Fq "$package"; then
                echo "$removing"
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
            ;;
        *)
            if apt list --installed "$package" 2>/dev/null | grep -Fq "$package"; then
                echo "$removing"
                sudo apt remove "$package"
            else
                no_package_found "$primary_pm" "$package"
            fi
            ;;
    esac
}

remove_dnf() {
    detect_system
    local package="$1"
    local removing="$2"
    if dnf list --installed "$package" >/dev/null 2>&1; then
        echo "$removing"
        sudo dnf remove "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

remove_eopkg() {
    detect_system
    local package="$1"
    local removing="$2"
    if eopkg search -i --name "^$package" 2>/dev/null | grep -Fq "$package"; then
        echo "$removing"
        sudo eopkg remove "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

remove_pacman() {
    detect_system
    local package="$1"
    local removing="$2"
    case "$secondary_pm" in
        "paru"|"yay")
            if "$secondary_pm" -Qs "^$package$" >/dev/null 2>&1; then
                echo "$removing"
                "$secondary_pm" -Rs "$package"
            else
                no_package_found "$secondary_pm" "$package"
            fi
            ;;
        *)
            if pacman -Qs "^$package$" >/dev/null 2>&1; then
                echo "$removing"
                sudo pacman -Rs "$package"
            else
                no_package_found "$primary_pm" "$package"
            fi
            ;;
    esac
}

remove_xbps() {
    detect_system
    local package="$1"
    local removing="$2"
    if xbps-query -s "$package" | grep -Fiq "$package"; then
        echo "$removing"
        sudo xbps-remove -R "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

remove_zypper() {
    detect_system
    local package="$1"
    local removing="$2"
    if zypper se -i --match-exact "$package" >/dev/null 2>&1; then
        echo "$removing"
        sudo zypper rm --clean-deps "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

remove_flatpak_pkg() {
    local package="$1"
    local removing="$2"
    if flatpak list --columns=name,application | grep -Fiq "$package"; then
        echo "$removing"
        flatpak remove "$package"
    else
        no_package_found "flatpak" "$package"
        return 1
    fi
}

remove_snap_pkg() {
    local package="$1"
    local removing="$2"
    if snap list "$package" >/dev/null 2>&1; then
        echo "$removing"
        confirm sudo snap remove "$package"
    else
        no_package_found "snap" "$package"
        return 1
    fi
}

remove_toolbox_pkg() {
    local package="$1"
    local removing="$2"
    if toolbox run dnf list --installed "$package" >/dev/null 2>&1; then
        echo "$removing"
        toolbox run sudo dnf remove "$package"
    else
        no_package_found "dnf (toolbox)" "$package"
        return 1
    fi
}

remove_rpm_ostree() {
    detect_system
    local package="$1"
    local removing="$2"
    if rpm -qa | grep -q "^$package"; then
        echo "$removing"
        confirm sudo rpm-ostree remove "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

remove() {
    if [ $# -eq 0 ]; then
        echo "Enter a package name."
        return 1
    fi

    detect_system
    local managers=(apt dnf eopkg pacman xbps zypper flatpak snap toolbox rpm-ostree)

    for package in "$@"; do
        for manager in "${managers[@]}"; do
            local removing="${green}$manager:${reset} removing '$package'"

            case "$manager" in
                "apt")
                    if [ "$primary_pm" = "apt" ]; then
                        remove_apt "$package" "$removing"
                    fi
                    ;;
                "dnf")
                    if [ "$primary_pm" = "dnf" ]; then
                        remove_dnf "$package" "$removing"
                    fi
                    ;;
                "eopkg")
                    if [ "$primary_pm" = "eopkg" ]; then
                        remove_eopkg "$package" "$removing"
                    fi
                    ;;
                "pacman")
                    if [ "$primary_pm" = "pacman" ]; then
                        remove_pacman "$package" "$removing"
                    fi
                    ;;
                "xbps")
                    if [ "$primary_pm" = "xbps" ]; then
                        remove_xbps "$package" "$removing"
                    fi
                    ;;
                "zypper")
                    if [ "$primary_pm" = "zypper" ]; then
                        remove_zypper "$package" "$removing"
                    fi
                    ;;
                "flatpak")
                    if [ "$flatpak_installed" -eq 1 ]; then
                        remove_flatpak_pkg "$package" "$removing" && break
                    fi
                    ;;
                "snap")
                    if [ "$snap_installed" -eq 1 ]; then
                        remove_snap_pkg "$package" "$removing" && break
                    fi
                    ;;
                "toolbox")
                    if [ "$toolbox_installed" -eq 1 ]; then
                        remove_toolbox_pkg "$package" "$removing" && break
                    fi
                    ;;
                "rpm-ostree")
                    if [ "$primary_pm" = "rpm-ostree" ]; then
                        remove_rpm_ostree "$package" "$removing"
                    fi
                    ;;
            esac

            case "$package" in
                "cinnamon-spice-updater"|"distrobox"|"flatpak"|"fwupd"|"nala"|"snap"|"toolbox"|"waydroid")
                    source "$HOME/.bashrc"
                    ;;
            esac
        done
    done
}
