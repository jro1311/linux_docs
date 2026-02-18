unlock_apt() {
    local package="$1"
    local unlocking="$2"
    if apt list --installed "$package" 2>/dev/null | grep -Fiq "$package"; then
        echo "$unlocking"
        sudo apt-mark unhold "$package"
    else
        no_package_found "$secondary_package_manager" "$package"
    fi
}

unlock_dnf() {
    local package="$1"
    local unlocking="$2"
    if dnf list --installed "$package" >/dev/null 2>&1; then
        echo "$unlocking"
        sudo dnf versionlock delete "$package"
    else
        no_package_found "$primary_package_manager" "$package"
    fi
}

unlock_pacman() {
    local package="$1"
    local unlocking="$2"
    if grep -q "^#IgnorePkg" /etc/pacman.conf; then
        sudo sed -i 's/^#IgnorePkg/IgnorePkg/' /etc/pacman.conf
    fi

    if grep -Fq "$package" /etc/pacman.conf; then
        echo "$unlocking"
        #sudo sed -i "/^IgnorePkg/s/$package//g" /etc/pacman.conf
        #sudo sed -i "/^IgnorePkg/ s/\([[:space:]]\+\)$package[[:space:]]\+/\1/g; s/^$package[[:space:]]\+//; s/[[:space:]]\+$//" /etc/pacman.conf
        sudo sed -i "/^IgnorePkg/ {
            s/^IgnorePkg[[:space:]]*=[[:space:]]*$package[[:space:]]*$//;  # Remove if it's the only entry
            s/[[:space:]]*$package[[:space:]]*//;                      # Remove if it's the last one, keeping spaces before
            s/=[[:space:]]*$/=/;                                     # Clean up the line if now just '='
            s/=[[:space:]]+/=/;                                      # Normalize any spaces after '='
        }" /etc/pacman.conf
    else
        no_package_found "$primary_package_manager" "$package"
    fi
}

unlock_xbps() {
    local package="$1"
    local unlocking="$2"
    if xbps-query -s "$package" | grep -Fiq "$package"; then
        echo "$unlocking"
        sudo xbps-query hold "$package"
    else
        no_package_found "$primary_package_manager" "$package"
    fi
}

unlock_zypper() {
    local package="$1"
    local unlocking="$2"
    if zypper se -i --match-exact "$package" >/dev/null 2>&1; then
        echo "$unlocking"
        sudo zypper al "$package"
    else
        no_package_found "$primary_package_manager" "$package"
    fi
}

unlock_flatpak_pkg() {
    local package="$1"
    local unlocking="$2"
    if flatpak list --app --columns=ref | grep -q "^$package$"; then
        echo "$unlocking"
        flatpak pin "app/$package"
    elif flatpak list --runtime --columns=ref | grep -q "^$package$"; then
        echo "$unlocking"
        flatpak pin "runtime/$package"
    else
        no_package_found "flatpak" "$package"
        return 1
    fi
}

unlock_snap_pkg() {
    local package="$1"
    local unlocking="$2"
    if snap list | awk '{print $1}' | grep -iq "^$package"; then
        echo "$unlocking"
        confirm sudo snap enable "$package"
    else
        no_package_found "snap" "$package"
        return 1
    fi
}

unlock_toolbox_pkg() {
    local package="$1"
    local unlocking="$2"
    if toolbox run dnf list --installed "$package" >/dev/null 2>&1; then
        echo "$unlocking"
        toolbox run sudo dnf versionlock delete "$package"
    else
        no_package_found "dnf (toolbox)" "$package"
        return 1
    fi
}

unlock() {
    if [ $# -eq 0 ]; then
        echo "Enter a package name."
        return 1
    fi

    local managers=(apt dnf eopkg pacman xbps zypper flatpak snap toolbox rpm-ostree)

    for package in "$@"; do
        for manager in "${managers[@]}"; do
            local unlocking="${green}Unlocking '$package' using $manager... ${reset}"
            local no_function_available="${yellow}Function not available using $manager. ${reset}"

            case "$manager" in
                "apt")
                    if [ "$primary_package_manager" = "apt" ]; then
                        unlock_apt "$package" "$unlocking"
                    fi
                    ;;
                "dnf")
                    if [ "$primary_package_manager" = "dnf" ]; then
                        unlock_dnf "$package" "$unlocking"
                    fi
                    ;;
                "eopkg")
                    if [ "$primary_package_manager" = "eopkg" ]; then
                        no_function_available
                    fi
                    ;;
                "pacman")
                    if [ "$primary_package_manager" = "pacman" ]; then
                        unlock_pacman "$package" "$unlocking"
                    fi
                    ;;
                "xbps")
                    if [ "$primary_package_manager" = "xbps" ]; then
                        unlock_xbps "$package" "$unlocking"
                    fi
                    ;;
                "zypper")
                    if [ "$primary_package_manager" = "zypper" ]; then
                        unlock_zypper "$package" "$unlocking"
                    fi
                    ;;
                "flatpak")
                    if [ "$flatpak_installed" -eq 1 ]; then
                        unlock_flatpak_pkg "$package" "$unlocking"
                    fi
                    ;;
                "snap")
                    if [ "$snap_installed" -eq 1 ]; then
                        unlock_snap_pkg "$package" "$unlocking"
                    fi
                    ;;
                "toolbox")
                    if [ "$toolbox_installed" -eq 1 ]; then
                        unlock_toolbox_pkg "$package" "$unlocking"
                    fi
                    ;;
                "rpm-ostree")
                    if [ "$primary_package_manager" = "rpm-ostree" ]; then
                        #unlock_rpm_ostree "$package" "$unlocking"
                        no_function_available
                    fi
                    ;;
            esac
        done
    done
}
