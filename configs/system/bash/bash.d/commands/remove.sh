# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_remove_nala_pkg() {
    local mode="${1:-manual}"
    local pkg="$2"
    local flags=()

    [ "$mode" = "auto" ] && flags+=(-y)

    if ! pkg_installed_pm "$pkg"; then
        no_pkg_found "$secondary_pm" "$pkg"
        return 1
    fi

    announce_remove "$secondary_pm" "$pkg"

    case "$pkg" in
        nala)
            if [ "$mode" = "auto" ]; then
                sudo apt-get purge "${flags[@]}" "$pkg" || :
            else
                sudo apt purge "$pkg" || :
            fi
            ;;
        *)
            sudo nala purge "${flags[@]}" "$pkg" || :
            ;;
    esac
}

_remove_apt_pkg() {
    local mode="${1:-manual}"
    local pkg="$2"
    local flags=()

    [ "$mode" = "auto" ] && flags+=(-y)

    if ! pkg_installed_pm "$pkg"; then
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi

    announce_remove "$primary_pm" "$pkg"

    if [ "$mode" = "auto" ]; then
        sudo apt-get purge "${flags[@]}" "$pkg" || :
    else
        sudo apt purge "$pkg" || :
    fi
}

_remove_dnf_pkg() {
    local mode="${1:-manual}"
    local pkg="$2"
    local flags=()

    [ "$mode" = "auto" ] && flags+=(-y)

    if ! pkg_installed_pm "$pkg"; then
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi

    announce_remove "$primary_pm" "$pkg"

    sudo dnf remove "${flags[@]}" "$pkg" || :
}

_remove_eopkg_pkg() {
    local mode="${1:-manual}"
    local pkg="$2"
    local flags=()

    [ "$mode" = "auto" ] && flags+=(-y)

    if ! pkg_installed_pm "$pkg"; then
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi

    announce_remove "$primary_pm" "$pkg"

    sudo eopkg remove "${flags[@]}" "$pkg" || :
}

_remove_aur_pkg() {
    local mode="${1:-manual}"
    local pkg="$2"
    local flags=(-Rns)

    [ "$mode" = "auto" ] && flags+=(--noconfirm)

    if ! pkg_installed_aur "$pkg"; then
        no_pkg_found "$secondary_pm" "$pkg"
        return 1
    fi

    announce_remove "$secondary_pm" "$pkg"

    "$secondary_pm" "${flags[@]}" "$pkg" || :
}

_remove_pacman_pkg() {
    local mode="${1:-manual}"
    local pkg="$2"
    local flags=(-Rns)

    [ "$mode" = "auto" ] && flags+=(--noconfirm)

    if ! pkg_installed_pm "$pkg"; then
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi

    announce_remove "$primary_pm" "$pkg"

    sudo pacman "${flags[@]}" "$pkg" || :
}

_remove_xbps_pkg() {
    local mode="${1:-manual}"
    local pkg="$2"
    local flags=(-R)

    [ "$mode" = "auto" ] && flags+=(-y)

    if ! pkg_installed_pm "$pkg"; then
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi

    announce_remove "$primary_pm" "$pkg"

    sudo xbps-remove "${flags[@]}" "$pkg" || :
}

_remove_zypper_pkg() {
    local mode="${1:-manual}"
    local pkg="$2"
    local flags=(--clean-deps)

    [ "$mode" = "auto" ] && flags+=(-y)

    if ! pkg_installed_pm "$pkg"; then
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi

    announce_remove "$primary_pm" "$pkg"

    sudo zypper rm "${flags[@]}" "$pkg" || :
}

_remove_rpm_ostree_pkg() {
    local mode="${1:-manual}"
    local pkg="$2"

    if ! pkg_installed_pm "$pkg"; then
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi

    announce_remove "$primary_pm" "$pkg"

    if [ "$mode" = "auto" ]; then
        sudo rpm-ostree remove "$pkg"
    else
        confirm "Confirm remove operation [y/N]" \
            && sudo rpm-ostree remove "$pkg" || :
    fi
}

_remove_toolbox_pkg() {
    local mode="${1:-manual}"
    local pkg="$2"
    local flags=()

    [ "$mode" = "auto" ] && flags+=(-y)

    if ! pkg_installed_toolbox "$pkg"; then
        no_pkg_found "toolbox" "$pkg"
        return 1
    fi

    announce_remove "toolbox" "$pkg"

    toolbox run sudo dnf remove "${flags[@]}" "$pkg" || :
}

_remove_flatpak_pkg() {
    local mode="${1:-manual}"
    local pkg="$2"
    local flags=()

    [ "$mode" = "auto" ] && flags+=(-y)

    if ! pkg_installed_flatpak "$pkg"; then
        no_pkg_found "flatpak" "$pkg"
        return 1
    fi

    announce_remove "flatpak" "$pkg"

    flatpak remove "${flags[@]}" "$pkg" || :
}

_remove_snap_pkg() {
    local mode="${1:-manual}"
    local pkg="$2"

    if ! pkg_installed_snap "$pkg"; then
        no_pkg_found "snap" "$pkg"
        return 1
    fi

    announce_remove "snap" "$pkg"

    if [ "$mode" = "auto" ]; then
        sudo snap remove "$pkg"
    else
        confirm "Confirm remove operation [y/N]" \
            && sudo snap remove "$pkg" || :
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

    local mode="${1:-manual}"

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
