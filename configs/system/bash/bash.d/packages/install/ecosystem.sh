# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

install_snap() {
    detect_system

    if [ "$init_system" != "systemd" ]; then
        unsupported_init_system
        return 1
    fi

    if [ "$os" = "ubuntu" ]; then
        unlock_pm "$pkg"
    fi

    case "$primary_pm" in
        zypper)
            local url_prefix="https://download.opensuse.org/repositories/system:/snappy"

            case "$os" in
                opensuse-tumbleweed|opensuse-slowroll)
                    sudo zypper addrepo --refresh "$url_prefix"/openSUSE_Tumbleweed snappy >/dev/null || return 1
                    ;;
                opensuse-leap)
                    sudo zypper addrepo --refresh "$url_prefix"/openSUSE_Leap_16.0 snappy >/dev/null || return 1
                    ;;
                *)
                    unsupported_operating_system
                    return 1
                    ;;
            esac

            sudo zypper refresh --gpg-auto-import-keys >/dev/null || return 1
            ;;
    esac

    case "$primary_pm" in
        pacman)
            install_aur_pkg_bypass "snapd" || return 1
            ;;
        *)
            ensure_pkg "snapd" || return 1
            ;;
    esac

    configure_snap || return 1
}

install_waydroid() {
    detect_system
    case "$primary_pm" in
        apt)
            ensure_pkg "curl" "ca-certificates" || return 1
            curl -fsSL https://repo.waydro.id | sudo bash || return 1
            ;;
        xbps)
            ensure_pkg "python3-pyclip" "wl-clipboard" || return 1
            ;;
    esac

    ensure_pkg "waydroid" || return 1

    configure_waydroid || return 1
}
