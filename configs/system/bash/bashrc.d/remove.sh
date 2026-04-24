# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

remove_nala_pkg() {
    local mode="$1"
    local package="$2"
    detect_system

    if apt list --installed "$package" 2>/dev/null | grep -Fq "$package"; then
        case "$mode" in
            auto)
                case "$package" in
                    "nala")
                        sudo apt remove -y "$package"
                        ;;
                    *)
                        sudo nala remove -y "$package"
                        ;;
                esac
                ;;
            manual|*)
                case "$package" in
                    "nala")
                        sudo apt remove "$package"
                        ;;
                    *)
                        sudo nala remove "$package"
                        ;;
                esac
                ;;
        esac
    else
        no_package_found "$secondary_pm" "$package"
    fi
}

remove_apt_pkg() {
    local mode="$1"
    local package="$2"
    detect_system

    if apt list --installed "$package" 2>/dev/null | grep -Fq "$package"; then
        case "$mode" in
            auto)
                sudo apt remove -y "$package"
                ;;
            manual|*)
                sudo apt remove "$package"
                ;;
        esac
    else
        no_package_found "$primary_pm" "$package"
    fi
}

remove_dnf_pkg() {
    local mode="$1"
    local package="$2"
    detect_system

    if dnf list --installed "$package" >/dev/null 2>&1; then
        case "$mode" in
            auto)
                sudo dnf remove -y "$package"
                ;;
            manual|*)
                sudo dnf remove "$package"
                ;;
        esac
    else
        no_package_found "$primary_pm" "$package"
    fi
}

remove_eopkg_pkg() {
    local mode="$1"
    local package="$2"
    detect_system

    if eopkg search -i --name "^$package" 2>/dev/null | grep -Fq "$package"; then
        case "$mode" in
            auto)
                sudo eopkg remove -y "$package"
                ;;
            manual|*)
                sudo eopkg remove "$package"
                ;;
        esac
    else
        no_package_found "$primary_pm" "$package"
    fi
}

remove_aur_pkg() {
    local mode="$1"
    local package="$2"
    detect_system

    if "$secondary_pm" -Qs "^$package$" >/dev/null 2>&1; then
        case "$mode" in
            auto)
                "$secondary_pm" -Rs --noconfirm "$package"
                ;;
            manual|*)
                "$secondary_pm" -Rs "$package"
                ;;
        esac
    else
        no_package_found "$secondary_pm" "$package"
    fi
}

remove_pacman_pkg() {
    local mode="$1"
    local package="$2"
    detect_system

    if pacman -Qs "^$package$" >/dev/null 2>&1; then
        case "$mode" in
            auto)
                sudo pacman -Rs --noconfirm "$package"
                ;;
            manual|*)
                sudo pacman -Rs "$package"
                ;;
        esac
    else
        no_package_found "$primary_pm" "$package"
    fi
}

remove_xbps_pkg() {
    local mode="$1"
    local package="$2"
    detect_system

    if xbps-query -s "$package" | grep -Fiq "$package"; then
        case "$mode" in
            auto)
                sudo xbps-remove -Ry "$package"
                ;;
            manual|*)
                sudo xbps-remove -R "$package"
                ;;
        esac
    else
        no_package_found "$primary_pm" "$package"
    fi
}

remove_zypper_pkg() {
    local mode="$1"
    local package="$2"
    detect_system

    if zypper se -i --match-exact "$package" >/dev/null 2>&1; then
        case "$mode" in
            auto)
                sudo zypper rm --clean-deps -y "$package"
                ;;
            manual|*)
                sudo zypper rm --clean-deps "$package"
                ;;
        esac
    else
        no_package_found "$primary_pm" "$package"
    fi
}

remove_rpm_ostree_pkg() {
    local mode="$1"
    local package="$2"
    detect_system

    if rpm -qa | grep -q "^$package"; then
        check && {
            case "$mode" in
                auto)
                    sudo rpm-ostree remove "$package"
                    ;;
                manual|*)
                    confirm sudo rpm-ostree remove "$package"
                    ;;
            esac
        }
    else
        no_package_found "$primary_pm" "$package"
    fi
}

remove_toolbox_pkg() {
    local mode="$1"
    local package="$2"

    if toolbox run dnf list --installed "$package" >/dev/null 2>&1; then
        case "$mode" in
            auto)
                toolbox run sudo dnf remove -y "$package"
                ;;
            manual|*)
                toolbox run sudo dnf remove "$package"
                ;;
        esac
    else
        no_package_found "dnf (toolbox)" "$package"
        return 1
    fi
}

remove_flatpak_pkg() {
    local mode="$1"
    local package="$2"

    if flatpak list --columns=name,application | grep -Fiq "$package"; then
        case "$mode" in
            auto)
                flatpak remove -y "$package"
                ;;
            manual|*)
                flatpak remove "$package"
                ;;
        esac
    else
        no_package_found flatpak "$package"
        return 1
    fi
}

remove_snap_pkg() {
    local mode="$1"
    local package="$2"

    if snap list "$package" >/dev/null 2>&1; then
        case "$mode" in
            auto)
                sudo snap remove "$package"
                ;;
            manual|*)
                confirm sudo snap remove "$package"
                ;;
        esac
    else
        no_package_found snap "$package"
        return 1
    fi
}

remove_sm_pkg() {
    assert_arity "$#" "ge" 1 "<mode=manual> <package>" || return 1

    local mode
    case "$1" in
        manual|auto)
            mode="$1"
            shift
            ;;
        *)
            mode="manual"
            ;;
    esac

    local package="$1"
    detect_system

    case "$secondary_pm" in
        nala)
            announce_remove "$secondary_pm" "$package"
            remove_nala_pkg "$mode" "$package"
            ;;
        paru|yay)
            announce_remove "$secondary_pm" "$package"
            remove_aur_pkg "$mode" "$package"
            ;;
    esac
}

remove_pm_pkg() {
    assert_arity "$#" "ge" 1 "<mode=manual> <package>" || return 1

    local mode
    case "$1" in
        manual|auto)
            mode="$1"
            shift
            ;;
        *)
            mode="manual"
            ;;
    esac

    local package="$1"
    detect_system

    case "$primary_pm" in
        apt)
            announce_remove "$primary_pm" "$package"
            remove_apt_pkg "$mode" "$package"
            ;;
        dnf)
            announce_remove "$primary_pm" "$package"
            remove_dnf_pkg "$mode" "$package"
            ;;
        eopkg)
            announce_remove "$primary_pm" "$package"
            remove_eopkg_pkg "$mode" "$package"
            ;;
        pacman)
            announce_remove "$primary_pm" "$package"
            remove_pacman_pkg "$mode" "$package"
            ;;
        xbps)
            announce_remove "$primary_pm" "$package"
            remove_xbps_pkg "$mode" "$package"
            ;;
        zypper)
            announce_remove "$primary_pm" "$package"
            remove_zypper_pkg "$mode" "$package"
            ;;
        rpm-ostree)
            announce_remove "$primary_pm" "$package"
            remove_rpm_ostree_pkg "$mode" "$package"
            ;;
    esac
}

remove_optionals_pkg() {
   assert_arity "$#" "ge" 1 "<mode=manual> <package>" || return 1

    local mode
    case "$1" in
        manual|auto)
            mode="$1"
            shift
            ;;
        *)
            mode="manual"
            ;;
    esac

    local package="$1"
    detect_system

    optionals=(
        toolbox
        flatpak
        snap
    )

    for option in "${optionals[@]}"; do
        case "$option" in
            toolbox)
                if [ "$toolbox_installed" -eq 1 ]; then
                    announce_remove "$option" "$package"
                    remove_toolbox_pkg "$mode" "$package" && return 0
                fi
                ;;
            flatpak)
                if [ "$flatpak_installed" -eq 1 ]; then
                    announce_remove "$option" "$package"
                    remove_flatpak_pkg "$mode" "$package" && return 0
                fi
                ;;
            snap)
                if [ "$snap_installed" -eq 1 ]; then
                    announce_remove "$option" "$package"
                    remove_snap_pkg "$mode" "$package" && return 0
                fi
                ;;
        esac
    done

    return 1
}

remove_pkg() {
    assert_arity "$#" "ge" 1 "<mode=manual> <package>"

    local mode
    case "$1" in
        manual|auto)
            mode="$1"
            shift
            ;;
        *)
            mode="manual"
            ;;
    esac

    local package="$1"
    detect_system

    for package in "$@"; do
        case "$primary_pm" in
            rpm-ostree)
                remove_optionals_pkg "$mode" "$package" && continue
                remove_pm_pkg "$mode" "$package"
                ;;
            *)
                if [ -n "$secondary_pm" ]; then
                    remove_sm_pkg "$mode" "$package"
                else
                    remove_pm_pkg "$mode" "$package"
                fi

                remove_optionals_pkg "$mode" "$package"
                ;;
        esac

        case "$package" in
            flatpak|snap|toolbox)
                detect_optionals
                ;;
            nala)
                detect_secondary_pm
                ;;
        esac
    done
}

remove_pm_pkg_bypass() {
    [ "$#" -eq 0 ] && return 0

    detect_system
    case "$primary_pm" in
        apt)        sudo apt-get remove -y "$@" || true ;;
        dnf)        sudo dnf remove -y "$@" || true ;;
        eopkg)      sudo eopkg remove -y "$@" || true ;;
        pacman)     sudo pacman -Rs --noconfirm "$@" || true ;;
        xbps)       sudo xbps-remove -Ry "$@" || true ;;
        zypper)     sudo zypper rm --clean-deps -y "$@" || true ;;
        rpm-ostree) sudo rpm-ostree remove "$@" || true ;;
    esac

    return 0
}

remove_aur_pkg_bypass() {
    [ "$#" -eq 0 ] && return 0

    detect_system
    case "$primary_pm" in
        pacman)
            case "$secondary_pm" in
                paru|yay)
                    "$secondary_pm" -Rs --noconfirm "$@" || true
                    ;;
                *)
                    install_yay || return 1
                    secondary_pm="yay"
                    "$secondary_pm" -Rs --noconfirm "$@" || true
                    ;;
            esac
            ;;
    esac

    return 0
}

remove_flatpak_pkg_bypass() {
    [ "$#" -eq 0 ] && return 0

    detect_system
    [ "$flatpak_installed" -eq 0 ] && return 0

    flatpak remove -y "$@" || true
}

drop_packages() {
    [ "$#" -eq 0 ] && return 0

    detect_system
    local spec cmd pkg

    for spec in "$@"; do
        pkg="${spec%%:*}"
        cmd="${spec#*:}"

        [ "$cmd" = "$spec" ] && cmd="$pkg"

        if command -v "$cmd" >/dev/null 2>&1; then
            case "$primary_pm" in
                rpm-ostree)
                    install_pm_pkg "auto" "$pkg" || return 1
                    return 0
                    ;;
                *)
                    install_pm_pkg "auto" "$pkg" || return 1
                    return 0
                    ;;
            esac
        fi
    done
}

remove_defaults() {
    local pm="$primary_pm"
    local list="remove_list_${pm}[@]"

    remove_pm_pkg_bypass "${!list}" || true

    if [ "$snap_installed" -eq 1 ]; then
        sudo snap remove "${remove_list_snap[@]}" || true
    fi
}

remove_zram() {
    detect_system
    remove_pm_pkg_bypass "${zram_pkg[$primary_pm]}"

    case "$init_system" in
        systemd)
            if [ -f /etc/systemd/zram-generator.conf ]; then
                sudo rm -v /etc/systemd/zram-generator.conf
            fi

            sudo systemctl daemon-reload
            ;;
        dinit|openrc|runit|s6|sysvinit)
            sudo sed -i '/zramen/d' /etc/rc.local

            if [ -f /etc/modules-load.d/zram.conf ]; then
                sudo rm -v /etc/modules-load.d/zram.conf
            fi

            if [ -f /etc/udev/rules.d/99-zram.rules ]; then
                sudo rm -v /etc/udev/rules.d/99-zram.rules
            fi

            sudo sed -i '/\/dev\/zram0/d' /etc/fstab
    esac

    if [ -f /etc/sysctl.d/99-zram.conf ]; then
        sudo rm -v /etc/sysctl.d/99-zram.conf
    fi

    # Switches zram meter with swap in htop
    if [ -f "$HOME/.config/htop/htoprc" ]; then
        sed -i 's/Zram/Swap/g' "$HOME/.config/htop/htoprc"
    fi
}
