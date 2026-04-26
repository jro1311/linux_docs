# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_lock_apt() {
    local pkg="$1"

    if apt list "$pkg" 2>/dev/null | grep -Fq "$pkg"; then
        sudo apt-mark hold "$pkg"
    else
        no_pkg_found "$primary_pm" "$pkg"
    fi
}

_lock_dnf() {
    local pkg="$1"

    if dnf list --available "$pkg" >/dev/null 2>&1; then
        sudo dnf versionlock add "$pkg"
    else
        no_pkg_found "$primary_pm" "$pkg"
    fi
}

_lock_pacman() {
    local pkg="$1"

    if grep -q "^#IgnorePkg" /etc/pacman.conf; then
        sudo sed -i 's/^#IgnorePkg/IgnorePkg/' /etc/pacman.conf
    fi

    if ! grep -Fq "$pkg" /etc/pacman.conf; then
        sudo sed -i \
            "/^IgnorePkg[[:space:]]*=/ {
                s/[[:space:]]*$/ $pkg/
            }" \
            /etc/pacman.conf
    else
        no_pkg_found "$primary_pm" "$pkg"
    fi
}

_lock_xbps() {
    local pkg="$1"

    if xbps-query -s "$pkg" | grep -Fq "$pkg"; then
        sudo xbps-pkgdb -m hold "$pkg"
    else
        no_pkg_found "$primary_pm" "$pkg"
    fi
}

_lock_zypper() {
    local pkg="$1"

    if zypper se --match-exact "$pkg" >/dev/null 2>&1; then
        sudo zypper al "$pkg"
    else
        no_pkg_found "$primary_pm" "$pkg"
    fi
}

_lock_toolbox_pkg() {
    local pkg="$1"

    if toolbox run dnf list --available "$pkg" >/dev/null 2>&1; then
        toolbox run sudo dnf versionlock add "$pkg"
    else
        no_pkg_found "dnf (toolbox)" "$pkg"
        return 1
    fi
}

_lock_flatpak_pkg() {
    local pkg="$1"

    if flatpak list --app --columns=app | grep -Fq "$pkg"; then
        local full_pkg="app/$pkg"
        flatpak mask "$full_pkg"

    elif flatpak list --runtime --columns=app | grep -Fq "$pkg"; then
        local full_pkg="runtime/$pkg"
        flatpak mask "$full_pkg"
    else
        no_pkg_found "flatpak" "$pkg"
        return 1
    fi
}

_lock_snap_pkg() {
    local pkg="$1"

    if snap list "$pkg" >/dev/null 2>&1; then
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
            announce_lock "$primary_pm" "$pkg"
            _lock_apt "$pkg"
            ;;
        dnf)
            announce_lock "$primary_pm" "$pkg"
            _lock_dnf "$pkg"
            ;;
        eopkg)
            no_function_available "$primary_pm"
            ;;
        pacman)
            announce_lock "$primary_pm" "$pkg"
            _lock_pacman "$pkg"
            ;;
        xbps)
            announce_lock "$primary_pm" "$pkg"
            _lock_xbps "$pkg"
            ;;
        zypper)
            announce_lock "$primary_pm" "$pkg"
            _lock_zypper "$pkg"
            ;;
        rpm-ostree)
            no_function_available "$primary_pm"
            ;;
    esac
}

lock_optionals() {
    local pkg="$1"

    optionals=(
        toolbox
        flatpak
        snap
    )

    for option in "${optionals[@]}"; do
        case "$option" in
            toolbox)
                if [ "$toolbox_installed" -eq 1 ]; then
                    announce_lock "$option" "$pkg"
                    _lock_toolbox_pkg "$pkg"
                fi
                ;;
            flatpak)
                if [ "$flatpak_installed" -eq 1 ]; then
                    announce_lock "$option" "$pkg"
                    _lock_flatpak_pkg "$pkg"
                fi
                ;;
            snap)
                if [ "$snap_installed" -eq 1 ]; then
                    announce_lock "$option" "$pkg"
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
