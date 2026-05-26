# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_remove_nala_pkg() {
    local mode="$1"
    local pkg="$2"

    if dpkg -s "$pkg" >/dev/null 2>&1; then
        case "$mode" in
            auto)
                case "$pkg" in
                    "nala")
                        sudo apt-get remove -y "$pkg"
                        ;;
                    *)
                        sudo nala remove -y "$pkg"
                        ;;
                esac
                ;;
            manual|*)
                case "$pkg" in
                    "nala")
                        sudo apt remove "$pkg"
                        ;;
                    *)
                        sudo nala remove "$pkg"
                        ;;
                esac
                ;;
        esac
    else
        no_pkg_found "$secondary_pm" "$pkg"
        return 1
    fi
}

_remove_apt_pkg() {
    local mode="$1"
    local pkg="$2"

    if dpkg -s "$pkg" >/dev/null 2>&1; then
        case "$mode" in
            auto)
                sudo apt-get remove -y "$pkg"
                ;;
            manual|*)
                sudo apt remove "$pkg"
                ;;
        esac
    else
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi
}

_remove_dnf_pkg() {
    local mode="$1"
    local pkg="$2"

    if rpm -q "$pkg" >/dev/null 2>&1; then
        case "$mode" in
            auto)
                sudo dnf remove -y "$pkg"
                ;;
            manual|*)
                sudo dnf remove "$pkg"
                ;;
        esac
    else
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi
}

_remove_eopkg_pkg() {
    local mode="$1"
    local pkg="$2"

    if eopkg search -i --name "^$pkg$" 2>/dev/null \
        | awk -F' - ' '{print $1}' \
        | grep -Fq "$pkg"; then

        case "$mode" in
            auto)
                sudo eopkg remove -y "$pkg"
                ;;
            manual|*)
                sudo eopkg remove "$pkg"
                ;;
        esac
    else
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi
}

_remove_aur_pkg() {
    local mode="$1"
    local pkg="$2"

    if "$secondary_pm" -Qq "$pkg" >/dev/null 2>&1; then
        case "$mode" in
            auto)
                "$secondary_pm" -Rs --noconfirm "$pkg"
                ;;
            manual|*)
                "$secondary_pm" -Rs "$pkg"
                ;;
        esac
    else
        no_pkg_found "$secondary_pm" "$pkg"
        return 1
    fi
}

_remove_pacman_pkg() {
    local mode="$1"
    local pkg="$2"

    if pacman -Qq "$pkg" >/dev/null 2>&1; then
        case "$mode" in
            auto)
                sudo pacman -Rs --noconfirm "$pkg"
                ;;
            manual|*)
                sudo pacman -Rs "$pkg"
                ;;
        esac
    else
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi
}

_remove_xbps_pkg() {
    local mode="$1"
    local pkg="$2"

    if xbps-query -p pkgver "$pkg" >/dev/null 2>&1; then
        case "$mode" in
            auto)
                sudo xbps-remove -Ry "$pkg"
                ;;
            manual|*)
                sudo xbps-remove -R "$pkg"
                ;;
        esac
    else
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi
}

_remove_zypper_pkg() {
    local mode="$1"
    local pkg="$2"

    if zypper se -i --match-exact "$pkg" >/dev/null 2>&1; then
        case "$mode" in
            auto)
                sudo zypper rm --clean-deps -y "$pkg"
                ;;
            manual|*)
                sudo zypper rm --clean-deps "$pkg"
                ;;
        esac
    else
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi
}

_remove_rpm_ostree_pkg() {
    local mode="$1"
    local pkg="$2"

    if rpm -q "$pkg" >/dev/null 2>&1; then
        case "$mode" in
            auto)
                sudo rpm-ostree remove "$pkg"
                ;;
            manual|*)
                confirm "Confirm remove operation [y/N]" sudo rpm-ostree remove "$pkg"
                ;;
        esac
    else
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi
}

_remove_toolbox_pkg() {
    local mode="$1"
    local pkg="$2"

    if toolbox run rpm -q "$pkg" >/dev/null 2>&1; then
        case "$mode" in
            auto)
                toolbox run sudo dnf remove -y "$pkg"
                ;;
            manual|*)
                toolbox run sudo dnf remove "$pkg"
                ;;
        esac
    else
        no_pkg_found "dnf (toolbox)" "$pkg"
        return 1
    fi
}

_remove_flatpak_pkg() {
    local mode="$1"
    local pkg="$2"

    if flatpak list --columns=application | grep -Fiq "$pkg"; then
        case "$mode" in
            auto)
                flatpak remove -y "$pkg"
                ;;
            manual|*)
                flatpak remove "$pkg"
                ;;
        esac
    else
        no_pkg_found "flatpak" "$pkg"
        return 1
    fi
}

_remove_snap_pkg() {
    local mode="$1"
    local pkg="$2"

    if snap list "$pkg" >/dev/null 2>&1; then
        case "$mode" in
            auto)
                sudo snap remove "$pkg"
                ;;
            manual|*)
                confirm "Confirm remove operation [y/N]" sudo snap remove "$pkg"
                ;;
        esac
    else
        no_pkg_found "snap" "$pkg"
        return 1
    fi
}

remove_sm_pkg() {
    local mode pkg

    case "$1" in
        manual|auto)
            mode="$1"
            shift
            ;;
        *)
            mode="manual"
            ;;
    esac

    pkg="$1"

    case "$secondary_pm" in
        nala)
            announce_remove "$secondary_pm" "$pkg"
            _remove_nala_pkg "$mode" "$pkg"
            ;;
        paru|yay)
            announce_remove "$secondary_pm" "$pkg"
            _remove_aur_pkg "$mode" "$pkg"
            ;;
    esac
}

remove_pm_pkg() {
    local mode pkg

    case "$1" in
        manual|auto)
            mode="$1"
            shift
            ;;
        *)
            mode="manual"
            ;;
    esac

    pkg="$1"

    case "$primary_pm" in
        apt)
            announce_remove "$primary_pm" "$pkg"
            _remove_apt_pkg "$mode" "$pkg"
            ;;
        dnf)
            announce_remove "$primary_pm" "$pkg"
            _remove_dnf_pkg "$mode" "$pkg"
            ;;
        eopkg)
            announce_remove "$primary_pm" "$pkg"
            _remove_eopkg_pkg "$mode" "$pkg"
            ;;
        pacman)
            announce_remove "$primary_pm" "$pkg"
            _remove_pacman_pkg "$mode" "$pkg"
            ;;
        xbps)
            announce_remove "$primary_pm" "$pkg"
            _remove_xbps_pkg "$mode" "$pkg"
            ;;
        zypper)
            announce_remove "$primary_pm" "$pkg"
            _remove_zypper_pkg "$mode" "$pkg"
            ;;
        rpm-ostree)
            announce_remove "$primary_pm" "$pkg"
            _remove_rpm_ostree_pkg "$mode" "$pkg"
            ;;
    esac
}

remove_optionals_pkg() {
    local mode pkg

    case "$1" in
        manual|auto)
            mode="$1"
            shift
            ;;
        *)
            mode="manual"
            ;;
    esac

    pkg="$1"

    optionals=(
        toolbox
        flatpak
        snap
    )

    for option in "${optionals[@]}"; do
        case "$option" in
            toolbox)
                if [ "$toolbox_installed" -eq 1 ]; then
                    announce_remove "$option" "$pkg"
                    _remove_toolbox_pkg "$mode" "$pkg" && return 0
                fi
                ;;
            flatpak)
                if [ "$flatpak_installed" -eq 1 ]; then
                    announce_remove "$option" "$pkg"
                    _remove_flatpak_pkg "$mode" "$pkg" && return 0
                fi
                ;;
            snap)
                if [ "$snap_installed" -eq 1 ]; then
                    announce_remove "$option" "$pkg"
                    _remove_snap_pkg "$mode" "$pkg" && return 0
                fi
                ;;
        esac
    done

    return 1
}

remove_pkg() {
    assert_arity "$#" "ge" 1 "<mode=manual> <pkg>" || return 1

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

    detect_system

    for pkg in "$@"; do
        case "$primary_pm" in
            rpm-ostree)
                remove_optionals_pkg "$mode" "$pkg" && continue
                remove_pm_pkg "$mode" "$pkg"
                ;;
            *)
                if [ -n "$secondary_pm" ]; then
                    remove_sm_pkg "$mode" "$pkg"
                else
                    remove_pm_pkg "$mode" "$pkg"
                fi

                remove_optionals_pkg "$mode" "$pkg"
                ;;
        esac

        case "$pkg" in
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
        apt)        sudo apt-get remove -y "$@" || : ;;
        dnf)        sudo dnf remove -y "$@" || : ;;
        eopkg)      sudo eopkg remove -y "$@" || : ;;
        pacman)     sudo pacman -Rs --noconfirm "$@" || : ;;
        xbps)       sudo xbps-remove -Ry "$@" || : ;;
        zypper)     sudo zypper rm --clean-deps -y "$@" || : ;;
        rpm-ostree) sudo rpm-ostree remove "$@" || : ;;
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
                    "$secondary_pm" -Rs --noconfirm "$@" || :
                    ;;
                *)
                    install_yay || return 1
                    secondary_pm="yay"
                    "$secondary_pm" -Rs --noconfirm "$@" || :
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

    flatpak remove -y "$@" || :
}

drop_pkg() {
    [ "$#" -eq 0 ] && return 0

    detect_system
    local spec cmd pkg

    for spec in "$@"; do
        pkg="${spec%%:*}"
        cmd="${spec#*:}"

        [ "$cmd" = "$spec" ] && cmd="$pkg"

        if command -v "$cmd" >/dev/null 2>&1; then
            remove_pm_pkg "auto" "$pkg" || return 1
            return 0
        fi
    done
}

remove_default_pkgs() {
    local pm="$primary_pm"
    local list="remove_list_${pm}[@]"

    remove_pm_pkg_bypass "${!list}" || :

    if [ "$snap_installed" -eq 1 ]; then
        sudo snap remove "${remove_list_snap[@]}" || :
    fi
}

remove_zram() {
    detect_system
    remove_pm_pkg_bypass "${zram_pkg[$primary_pm]}"

    sudo rm -f /etc/systemd/zram-generator.conf
    sudo rm -f /etc/modules-load.d/zram.conf
    sudo rm -f /etc/udev/rules.d/99-zram.rules
    sudo rm -f /etc/sysctl.d/99-zram.conf

    if [ -f /etc/modprobe.d/disable-auto-zram.conf ]; then
        sudo rm -f /etc/modprobe.d/disable-auto-zram.conf
        rebuild_initramfs
    fi

    sudo sed -i '/\/dev\/zram0/d' /etc/fstab
    [ -f /etc/rc.local ] && sudo sed -i '/zramen/d' /etc/rc.local

    case "$init_system" in
        systemd) sudo systemctl daemon-reload ;;
        *) ;;
    esac

    if [ -f "$HOME/.config/htop/htoprc" ]; then
        sed -i 's/\<Zram\>/Swap/' "$HOME/.config/htop/htoprc"
    fi
}
