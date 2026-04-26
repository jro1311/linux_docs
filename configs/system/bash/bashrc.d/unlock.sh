# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_unlock_apt() {
    local pkg="$1"

    if apt list "$pkg" 2>/dev/null | grep -Fq "$pkg"; then
        sudo apt-mark unhold "$pkg"
    else
        no_pkg_found "$primary_pm" "$pkg"
    fi
}

_unlock_dnf() {
    local pkg="$1"

    if dnf list --available "$pkg" >/dev/null 2>&1; then
        sudo dnf versionlock delete "$pkg"
    else
        no_pkg_found "$primary_pm" "$pkg"
    fi
}

_unlock_pacman() {
    local pkg="$1"

    if grep -q "^#IgnorePkg" /etc/pacman.conf; then
        sudo sed -i 's/^#IgnorePkg/IgnorePkg/' /etc/pacman.conf
    fi

    if grep -Fq "$pkg" /etc/pacman.conf; then
        sudo sed -i \
            "/^IgnorePkg/ {
                s/\([[:space:]]\+\)${pkg}[[:space:]]\+/\1/g
                s/^${pkg}[[:space:]]\+//
                s/[[:space:]]\+$//
            }" \
            /etc/pacman.conf
    else
        no_pkg_found "$primary_pm" "$pkg"
    fi
}

_unlock_xbps() {
    local pkg="$1"

    if xbps-query -s "$pkg" | grep -Fq "$pkg"; then
        sudo xbps-pkgdb -m unhold "$pkg"
    else
        no_pkg_found "$primary_pm" "$pkg"
    fi
}

_unlock_zypper() {
    local pkg="$1"

    if zypper se --match-exact "$pkg" >/dev/null 2>&1; then
        sudo zypper rl "$pkg"
    else
        no_pkg_found "$primary_pm" "$pkg"
    fi
}

_unlock_toolbox_pkg() {
    local pkg="$1"

    if toolbox run dnf list --available "$pkg" >/dev/null 2>&1; then
        toolbox run sudo dnf versionlock delete "$pkg"
    else
        no_pkg_found "dnf (toolbox)" "$pkg"
        return 1
    fi
}

_unlock_flatpak_pkg() {
    local pkg="$1"

    if flatpak list --app --columns=app | grep -Fq "$pkg"; then
        flatpak mask --remove "app/$pkg"

    elif flatpak list --runtime --columns=app | grep -Fq "$pkg"; then
        flatpak mask --remove "runtime/$pkg"
    else
        no_pkg_found flatpak "$pkg"
        return 1
    fi
}

_unlock_snap_pkg() {
    local pkg="$1"

    if snap list "$pkg" >/dev/null 2>&1; then
        confirm "Confirm unlock operation [y/N]" sudo snap refresh --unhold "$pkg"
    else
        no_pkg_found snap "$pkg"
        return 1
    fi
}

unlock_pm() {
    local pkg="$1"

    case "$primary_pm" in
        apt)
            announce_unlock "$primary_pm" "$pkg"
            _unlock_apt "$pkg"
            ;;
        dnf)
            announce_unlock "$primary_pm" "$pkg"
            _unlock_dnf "$pkg"
            ;;
        eopkg)
            no_function_available "$primary_pm"
            ;;
        pacman)
            announce_unlock "$primary_pm" "$pkg"
            _unlock_pacman "$pkg"
            ;;
        xbps)
            announce_unlock "$primary_pm" "$pkg"
            _unlock_xbps "$pkg"
            ;;
        zypper)
            announce_unlock "$primary_pm" "$pkg"
            _unlock_zypper "$pkg"
            ;;
        rpm-ostree)
            no_function_available "$primary_pm"
            ;;
    esac
}

unlock_optionals() {
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
                    announce_unlock "$option" "$pkg"
                    _unlock_toolbox_pkg "$pkg"
                fi
                ;;
            flatpak)
                if [ "$flatpak_installed" -eq 1 ]; then
                    announce_unlock "$option" "$pkg"
                    _unlock_flatpak_pkg "$pkg"
                fi
                ;;
            snap)
                if [ "$snap_installed" -eq 1 ]; then
                    announce_unlock "$option" "$pkg"
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
