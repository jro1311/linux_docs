# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

remove_pm_pkg_bypass() {
    [ "$#" -eq 0 ] && return 0

    detect_system
    green_message "$primary_pm:" "removing $# pkgs..."

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

    green_message "$secondary_pm:" "removing $# AUR pkgs..."
    "$secondary_pm" -Rs --noconfirm "$@" >/dev/null 2>&1 || :
}

drop_pkg() {
    [ "$#" -eq 0 ] && return 0

    detect_system
    local pkg norm_pkg
    local installed=()

    for pkg in "$@"; do
        norm_pkg=$(normalize_pkg "$pkg")

        if [ "$primary_pm" = "rpm-ostree" ]; then
            case "$norm_pkg" in
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

        if pkg_installed_pm "$norm_pkg"; then
            case "$norm_pkg" in
                libreoffice)
                    installed+=("libreoffice*")
                    ;;
                *)
                    installed+=("$norm_pkg")
                    ;;
            esac
        fi
    done

    if [ "${#installed[@]}" -gt 0 ]; then
        remove_pm_pkg_bypass "${installed[@]}" || :
    fi
}

_remove_pkg_by_category_and_key() {
    local category="$1"
    local key="$2"

    local selected_var="${category}"
    local selected="${!selected_var}"
    [ "$key" = "$selected" ] && return 0

    local native_var="${category}_native_pkgs"
    local flatpak_var="${category}_flatpak_pkgs"
    local snap_var="${category}_snap_pkgs"

    declare -n native_arr="$native_var"
    declare -n flatpak_arr="$flatpak_var"
    declare -n snap_arr="$snap_var"

    local native_pkg="${native_arr[$key]-}"
    local flatpak_pkg="${flatpak_arr[$key]-}"
    local snap_pkg="${snap_arr[$key]-}"

    if [ -n "$native_pkg" ]; then
        drop_pkg "$native_pkg"
    fi

    if [ "$flatpak_installed" -eq 1 ] && [ -n "$flatpak_pkg" ]; then
        flatpak remove -y "$flatpak_pkg" 2>/dev/null || :
    fi

    if [ "$snap_installed" -eq 1 ] && [ -n "$snap_pkg" ]; then
        sudo snap remove "$snap_pkg" 2>/dev/null || :
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
