# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_remove_nala_pkg() {
    local mode="$1"
    local pkg="$2"

    if pkg_installed_pm "$pkg"; then
        announce_remove "$secondary_pm" "$pkg"

        case "$mode" in
            auto)
                case "$pkg" in
                    nala)
                        sudo apt-get remove -y "$pkg"
                        ;;
                    *)
                        sudo nala remove -y "$pkg"
                        ;;
                esac
                ;;
            manual|*)
                case "$pkg" in
                    nala)
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

    if pkg_installed_pm "$pkg"; then
        announce_remove "$primary_pm" "$pkg"

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

    if pkg_installed_pm "$pkg"; then
        announce_remove "$primary_pm" "$pkg"

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

    if pkg_installed_pm "$pkg"; then
        announce_remove "$primary_pm" "$pkg"

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

    if pkg_installed_pm "$pkg"; then
        announce_remove "$secondary_pm" "$pkg"

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

    if pkg_installed_pm "$pkg"; then
        announce_remove "$primary_pm" "$pkg"

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

    if pkg_installed_pm "$pkg"; then
        announce_remove "$primary_pm" "$pkg"

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

    if pkg_installed_pm "$pkg"; then
        announce_remove "$primary_pm" "$pkg"

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

    if pkg_installed_pm "$pkg"; then
        announce_remove "$primary_pm" "$pkg"

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

    if pkg_installed_optionals "$pkg"; then
        announce_remove "toolbox" "$pkg"

        case "$mode" in
            auto)
                toolbox run sudo dnf remove -y "$pkg"
                ;;
            manual|*)
                toolbox run sudo dnf remove "$pkg"
                ;;
        esac
    else
        no_pkg_found "toolbox" "$pkg"
        return 1
    fi
}

_remove_flatpak_pkg() {
    local mode="$1"
    local pkg="$2"

    if pkg_installed_optionals "$pkg"; then
        announce_remove "flatpak" "$pkg"

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

    if pkg_installed_optionals "$pkg"; then
        announce_remove "snap" "$pkg"

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
        nala)       _remove_nala_pkg    "$mode" "$pkg" ;;
        paru|yay)   _remove_aur_pkg     "$mode" "$pkg" ;;
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
        apt)        _remove_apt_pkg         "$mode" "$pkg" ;;
        dnf)        _remove_dnf_pkg         "$mode" "$pkg" ;;
        eopkg)      _remove_eopkg_pkg       "$mode" "$pkg" ;;
        pacman)     _remove_pacman_pkg      "$mode" "$pkg" ;;
        xbps)       _remove_xbps_pkg        "$mode" "$pkg" ;;
        zypper)     _remove_zypper_pkg      "$mode" "$pkg" ;;
        rpm-ostree) _remove_rpm_ostree_pkg  "$mode" "$pkg" ;;
    esac
}

remove_optionals_pkg() {
    local mode pkg
    local option
    local -a optionals=(
        toolbox
        flatpak
        snap
    )

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

    for option in "${optionals[@]}"; do
        case "$option" in
            toolbox)
                if [ "$toolbox_installed" -eq 1 ]; then
                    _remove_toolbox_pkg "$mode" "$pkg" && return 0
                fi
                ;;
            flatpak)
                if [ "$flatpak_installed" -eq 1 ]; then
                    _remove_flatpak_pkg "$mode" "$pkg" && return 0
                fi
                ;;
            snap)
                if [ "$snap_installed" -eq 1 ]; then
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
    green_message "$primary_pm:" "removing ${#@} pkgs..."

    case "$primary_pm" in
        apt)        sudo apt-get remove -y "$@"         >/dev/null 2>&1 || : ;;
        dnf)        sudo dnf remove -y "$@"             >/dev/null 2>&1 || : ;;
        eopkg)      sudo eopkg remove -y "$@"           >/dev/null 2>&1 || : ;;
        pacman)     sudo pacman -Rs --noconfirm "$@"    >/dev/null 2>&1 || : ;;
        xbps)       sudo xbps-remove -Ry "$@"           >/dev/null 2>&1 || : ;;
        zypper)     sudo zypper rm --clean-deps -y "$@" >/dev/null 2>&1 || : ;;
        rpm-ostree) sudo rpm-ostree remove "$@"         >/dev/null 2>&1 || : ;;
    esac
}

remove_aur_pkg_bypass() {
    [ "$#" -eq 0 ] && return 0

    detect_system

    [ "$primary_pm" != "pacman" ] && return 0
    [ -z "$secondary_pm" ] && return 0

    green_message "$secondary_pm:" "removing AUR pkgs..."
    "$secondary_pm" -Rs --noconfirm "$@" 2>/dev/null || :
}

drop_pkg() {
    [ "$#" -eq 0 ] && return 0

    detect_system
    local pkg

    for pkg in "$@"; do
        if [ "$primary_pm" = "rpm-ostree" ]; then
            case "$pkg" in
                firefox)
                    sudo rpm-ostree override remove firefox firefox-langpacks 2>/dev/null || :
                    continue
                    ;;
                libreoffice)
                    sudo rpm-ostree override remove libreoffice 2>/dev/null || :
                    continue
                    ;;
            esac
        fi

        case "$pkg" in
            libreoffice)
                remove_pm_pkg_bypass libreoffice* || :
                ;;
            *)
                remove_pm_pkg_bypass "$pkg" || :
                ;;
        esac
    done
}

_remove_pkg_by_category_and_key() {
    local category="$1"
    local key="$2"

    local native_var="${category}_native_pkgs"
    local flatpak_var="${category}_flatpak_pkgs"
    local snap_var="${category}_snap_pkgs"

    declare -n native_arr="$native_var"
    declare -n flatpak_arr="$flatpak_var"
    declare -n snap_arr="$snap_var"

    if [[ -v native_arr[$key] ]]; then
        local native_pkg="${native_arr[$key]}"
        if [ -n "$native_pkg" ]; then
            drop_pkg "$native_pkg"
        fi
    fi

    if [ "$flatpak_installed" -eq 1 ] && [[ -v flatpak_arr[$key] ]]; then
        local flatpak_pkg="${flatpak_arr[$key]}"
        if [ -n "$flatpak_pkg" ]; then
            flatpak remove -y "$flatpak_pkg" 2>/dev/null || :
        fi
    fi

    if [ "$snap_installed" -eq 1 ] && [[ -v snap_arr[$key] ]]; then
        local snap_pkg="${snap_arr[$key]}"
        if [ -n "$snap_pkg" ]; then
            sudo snap remove "$snap_pkg" 2>/dev/null || :
        fi
    fi
}

remove_non_selected_pkg() {
    local category="$1"
    local selected="$2"
    shift 2

    detect_system

    local key
    for key in "$@"; do
        [ "$key" = "$selected" ] && continue
        _remove_pkg_by_category_and_key "$category" "$key"
    done
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
