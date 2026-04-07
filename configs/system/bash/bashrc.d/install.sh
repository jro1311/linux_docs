# shellcheck shell=bash
# shellcheck source=/dev/null
# shellcheck disable=SC2034,SC2154

install_apt() {
    detect_system
    local package="$1"
    local installing="$2"
    case "$secondary_pm" in
        "nala")
            if apt list "$package" 2>/dev/null | grep -Fiq "$package"; then
                echo "$installing"
                sudo nala install "$package"
            else
                no_package_found "$secondary_pm" "$package"
            fi
            ;;
        *)
            if apt list "$package" 2>/dev/null | grep -Fiq "$package"; then
                echo "$installing"
                sudo apt install "$package"
            else
                no_package_found "$primary_pm" "$package"
            fi
            ;;
    esac
}

install_dnf() {
    detect_system
    local package="$1"
    local installing="$2"
    if dnf list --available "$package" >/dev/null 2>&1; then
        echo "$installing"
        sudo dnf install "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

install_eopkg() {
    detect_system
    local package="$1"
    local installing="$2"
    if eopkg search --name "^$package" | grep -Fiq "$package"; then
        echo "$installing"
        sudo eopkg install "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

install_pacman() {
    detect_system
    local package="$1"
    local installing="$2"
    case "$secondary_pm" in
        "paru"|"yay")
            if "$secondary_pm" -Ss "^$package$" >/dev/null 2>&1; then
                echo "$installing"
                "$secondary_pm" -S --needed "$package"
            else
                no_package_found "$secondary_pm" "$package"
            fi
            ;;
        *)
            if pacman -Ss "^$package$" >/dev/null 2>&1; then
                echo "$installing"
                sudo pacman -S --needed "$package"
            else
                no_package_found "$primary_pm" "$package"
            fi
            ;;
    esac
}

install_xbps() {
    detect_system
    local package="$1"
    local installing="$2"
    if xbps-query -Rs "$package" | grep -Fiq "$package"; then
        echo "$installing"
        sudo xbps-install -S "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

install_zypper() {
    detect_system
    local package="$1"
    local installing="$2"
    if zypper se --match-exact "$package" >/dev/null 2>&1; then
        echo "$installing"
        sudo zypper in "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

install_flatpak_pkg() {
    local package="$1"
    local installing="$2"
    if flatpak search --columns=name,application "$package" | grep -Fiq "$package"; then
        echo "$installing"
        flatpak install "$package"
    else
        no_package_found "flatpak" "$package"
        return 1
    fi
}

install_snap_pkg() {
    local package="$1"
    local installing="$2"
    if snap find "$package" | awk '{print $1}' | grep -iq "^$package"; then
        echo "$installing"
        confirm sudo snap install "$package"
    else
        no_package_found "snap" "$package"
        return 1
    fi
}

install_toolbox_pkg() {
    local package="$1"
    local installing="$2"
    if toolbox run dnf list --available "$package" >/dev/null 2>&1; then
        echo "$installing"
        toolbox run sudo dnf install "$package"
    else
        no_package_found "dnf (toolbox)" "$package"
        return 1
    fi
}

install_rpm_ostree() {
    detect_system
    local package="$1"
    local installing="$2"
    if rpm-ostree search "$package" | awk 'NR > 2 {print $1}' | grep -iq "^$package"; then
        echo "$installing"
        confirm sudo rpm-ostree install "$package"
    else
        no_package_found "$primary_pm" "$package"
    fi
}

install() {
    if [ $# -eq 0 ]; then
        echo "Enter a package name."
        return 1
    fi

    detect_system
    local managers=(apt dnf eopkg pacman xbps zypper flatpak snap toolbox rpm-ostree)

    for package in "$@"; do
        for manager in "${managers[@]}"; do
            local installing="${green}$manager:${reset} installing '$package'"

            case "$manager" in
                "apt")
                    if [ "$primary_pm" = "apt" ]; then
                        install_apt "$package" "$installing"
                    fi
                    ;;
                "dnf")
                    if [ "$primary_pm" = "dnf" ]; then
                        install_dnf "$package" "$installing"
                    fi
                    ;;
                "eopkg")
                    if [ "$primary_pm" = "eopkg" ]; then
                        install_eopkg "$package" "$installing"
                    fi
                    ;;
                "pacman")
                    if [ "$primary_pm" = "pacman" ]; then
                        install_pacman "$package" "$installing"
                    fi
                    ;;
                "xbps")
                    if [ "$primary_pm" = "xbps" ]; then
                        install_xbps "$package" "$installing"
                    fi
                    ;;
                "zypper")
                    if [ "$primary_pm" = "zypper" ]; then
                        install_zypper "$package" "$installing"
                    fi
                    ;;
                "flatpak")
                    if [ "$flatpak_installed" -eq 1 ]; then
                        install_flatpak_pkg "$package" "$installing" && break
                    fi
                    ;;
                "snap")
                    if [ "$snap_installed" -eq 1 ]; then
                        install_snap_pkg "$package" "$installing" && break
                    fi
                    ;;
                "toolbox")
                    if [ "$toolbox_installed" -eq 1 ]; then
                        install_toolbox_pkg "$package" "$installing" && break
                    fi
                    ;;
                "rpm-ostree")
                    if [ "$primary_pm" = "rpm-ostree" ]; then
                        install_rpm_ostree "$package" "$installing"
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
