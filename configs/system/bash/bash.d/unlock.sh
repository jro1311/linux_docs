# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_unlock_apt() {
    local pkg="$1"

    if pkg_available_pm "$pkg"; then
        announce_unlock "$primary_pm" "$pkg"
        sudo apt-mark unhold "$pkg"
    else
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi
}

_unlock_dnf() {
    local pkg="$1"

    if pkg_available_pm "$pkg"; then
        announce_unlock "$primary_pm" "$pkg"
        sudo dnf versionlock delete "$pkg"
    else
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi
}

_unlock_pacman() {
    local pkg="$1"

    if grep -q "^#IgnorePkg" /etc/pacman.conf; then
        sudo sed -i 's/^#IgnorePkg/IgnorePkg/' /etc/pacman.conf
    fi

    if grep -Eq "^IgnorePkg[[:space:]]*=.*\<${pkg}\>" /etc/pacman.conf; then
        announce_unlock "$primary_pm" "$pkg"
        sudo sed -i \
            "/^IgnorePkg[[:space:]]*=/ {
                s/[[:space:]]${pkg}[[:space:]]/ /g
                s/[[:space:]]${pkg}\$/ /
                s/=${pkg}[[:space:]]/=/
                s/[[:space:]]\{2,\}/ /g
                s/[[:space:]]\+$//
            }" \
            /etc/pacman.conf
    fi

    grep "^IgnorePkg" /etc/pacman.conf
}

_unlock_xbps() {
    local pkg="$1"

    if pkg_available_pm "$pkg"; then
        announce_unlock "$primary_pm" "$pkg"
        sudo xbps-pkgdb -m unhold "$pkg"
    else
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi
}

_unlock_zypper() {
    local pkg="$1"

    if pkg_available_pm "$pkg"; then
        announce_unlock "$primary_pm" "$pkg"
        sudo zypper rl "$pkg"
    else
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi
}

_unlock_toolbox_pkg() {
    local pkg="$1"

    if pkg_available_optionals "$pkg"; then
        announce_unlock "toolbox" "$pkg"
        toolbox run sudo dnf versionlock delete "$pkg"
    else
        no_pkg_found "toolbox" "$pkg"
        return 1
    fi
}

_unlock_flatpak_pkg() {
    local pkg="$1"

    if ! pkg_installed_optionals "$pkg"; then
        no_pkg_found "flatpak" "$pkg"
        return 1
    fi

    if flatpak list --app --columns=application 2>/dev/null | grep -Fxq "$pkg"; then
        announce_unlock "flatpak" "$pkg"
        flatpak mask --remove "app/$pkg"

    elif flatpak list --runtime --columns=application 2>/dev/null | grep -Fxq "$pkg"; then
        announce_unlock "flatpak" "$pkg"
        flatpak mask --remove "runtime/$pkg"
    else
        no_pkg_found "flatpak" "$pkg"
        return 1
    fi
}

_unlock_snap_pkg() {
    local pkg="$1"

    if pkg_installed_optionals "$pkg"; then
        announce_unlock "snap" "$pkg"
        confirm "Confirm unlock operation [y/N]" sudo snap refresh --unhold "$pkg"
    else
        no_pkg_found "snap" "$pkg"
        return 1
    fi
}

unlock_pm() {
    local pkg="$1"

    case "$primary_pm" in
        apt)
            _unlock_apt "$pkg"
            ;;
        dnf)
            _unlock_dnf "$pkg"
            ;;
        eopkg)
            no_function_available "$primary_pm"
            ;;
        pacman)
            _unlock_pacman "$pkg"
            ;;
        xbps)
            _unlock_xbps "$pkg"
            ;;
        zypper)
            _unlock_zypper "$pkg"
            ;;
        rpm-ostree)
            no_function_available "$primary_pm"
            ;;
    esac
}

unlock_optionals() {
    local pkg="$1"
    local option
    local -a optionals=(
        toolbox
        flatpak
        snap
    )

    for option in "${optionals[@]}"; do
        case "$option" in
            toolbox)
                if [ "$toolbox_installed" -eq 1 ]; then
                    _unlock_toolbox_pkg "$pkg"
                fi
                ;;
            flatpak)
                if [ "$flatpak_installed" -eq 1 ]; then
                    _unlock_flatpak_pkg "$pkg"
                fi
                ;;
            snap)
                if [ "$snap_installed" -eq 1 ]; then
                    _unlock_snap_pkg "$pkg"
                fi
                ;;
        esac
    done
}

unlock() {
    assert_arity "$#" "ge" 1 "<pkg>" || return 1

    detect_system

    for pkg in "$@"; do
        case "$primary_pm" in
            rpm-ostree)
                unlock_optionals "$pkg"
                unlock_pm "$pkg"
                ;;
            *)
                unlock_pm "$pkg"
                unlock_optionals "$pkg"
                ;;
        esac
    done
}
