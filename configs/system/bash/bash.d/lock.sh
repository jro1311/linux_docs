# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_lock_apt() {
    local pkg="$1"

    if pkg_available_pm "$pkg"; then
        announce_lock "$primary_pm" "$pkg"
        sudo apt-mark hold "$pkg"
    else
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi
}

_lock_dnf() {
    local pkg="$1"

    if pkg_available_pm "$pkg"; then
        announce_lock "$primary_pm" "$pkg"
        sudo dnf versionlock add "$pkg"
    else
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi
}

_lock_pacman() {
    local pkg="$1"

    if grep -q "^#IgnorePkg" /etc/pacman.conf; then
        sudo sed -i 's/^#IgnorePkg/IgnorePkg/' /etc/pacman.conf
    fi

    if ! grep -Eq "^IgnorePkg[[:space:]]*=.*\<${pkg}\>" /etc/pacman.conf; then
        announce_lock "$primary_pm" "$pkg"
        sudo sed -i \
            "/^IgnorePkg[[:space:]]*=/ {
                s/[[:space:]]*$/ ${pkg}/
            }" \
            /etc/pacman.conf
    fi

    grep "^IgnorePkg" /etc/pacman.conf
}

_lock_xbps() {
    local pkg="$1"

    if pkg_available_pm "$pkg"; then
        announce_lock "$primary_pm" "$pkg"
        sudo xbps-pkgdb -m hold "$pkg"
    else
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi
}

_lock_zypper() {
    local pkg="$1"

    if pkg_available_pm "$pkg"; then
        announce_lock "$primary_pm" "$pkg"
        sudo zypper al "$pkg"
    else
        no_pkg_found "$primary_pm" "$pkg"
        return 1
    fi
}

_lock_toolbox_pkg() {
    local pkg="$1"

    if pkg_available_optionals "$pkg"; then
        announce_lock "toolbox" "$pkg"
        toolbox run sudo dnf versionlock add "$pkg"
    else
        no_pkg_found "toolbox" "$pkg"
        return 1
    fi
}

_lock_flatpak_pkg() {
    local pkg="$1"

    if ! pkg_installed_optionals "$pkg"; then
        no_pkg_found "flatpak" "$pkg"
        return 1
    fi

    if flatpak list --app --columns=application 2>/dev/null | grep -Fxq "$pkg"; then
        announce_lock "flatpak" "$pkg"
        flatpak mask "app/$pkg"

    elif flatpak list --runtime --columns=application 2>/dev/null | grep -Fxq "$pkg"; then
        announce_lock "flatpak" "$pkg"
        flatpak mask "runtime/$pkg"
    else
        no_pkg_found "flatpak" "$pkg"
        return 1
    fi
}

_lock_snap_pkg() {
    local pkg="$1"

    if pkg_installed_optionals "$pkg"; then
        announce_lock "snap" "$pkg"
        confirm "Confirm lock operation [y/N]" sudo snap refresh --hold "$pkg"
    else
        no_pkg_found "snap" "$pkg"
        return 1
    fi
}

lock_pm() {
    local pkg="$1"

    case "$primary_pm" in
        apt)
            _lock_apt "$pkg"
            ;;
        dnf)
            _lock_dnf "$pkg"
            ;;
        eopkg)
            no_function_available "$primary_pm"
            ;;
        pacman)
            _lock_pacman "$pkg"
            ;;
        xbps)
            _lock_xbps "$pkg"
            ;;
        zypper)
            _lock_zypper "$pkg"
            ;;
        rpm-ostree)
            no_function_available "$primary_pm"
            ;;
    esac
}

lock_optionals() {
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
                    _lock_toolbox_pkg "$pkg"
                fi
                ;;
            flatpak)
                if [ "$flatpak_installed" -eq 1 ]; then
                    _lock_flatpak_pkg "$pkg"
                fi
                ;;
            snap)
                if [ "$snap_installed" -eq 1 ]; then
                    _lock_snap_pkg "$pkg"
                fi
                ;;
        esac
    done
}

lock() {
    assert_arity "$#" "ge" 1 "<pkg>" || return 1

    detect_system

    for pkg in "$@"; do
        case "$primary_pm" in
            rpm-ostree)
                lock_optionals "$pkg"
                lock_pm "$pkg"
                ;;
            *)
                lock_pm "$pkg"
                lock_optionals "$pkg"
                ;;
        esac
    done
}
