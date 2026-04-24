# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

install_snap() {
    detect_system
    if [ "$init_system" != "systemd" ]; then
        unsupported_init_system
        return 1
    fi

    case "$primary_pm" in
        apt)
            # Unlocks package(s) if they are locked
            if apt-mark showhold "snapd" 2>/dev/null | grep -Fq "snapd"; then
                sudo apt-mark unhold snapd
            fi
            ;;
        zypper)
            case "$os" in
                opensuse-tumbleweed|opensuse-slowroll)
                    sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Tumbleweed snappy
                    ;;
                opensuse-leap)
                    sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Leap_16.0 snappy
                    ;;
                *)
                    unsupported_operating_system
                    return 1
                    ;;
            esac

            sudo zypper --gpg-auto-import-keys refresh
            ;;
        *)
            unsupported_package_manager
            return 1
            ;;
    esac

    case "$primary_pm" in
        pacman)
            install_aur_pkg_bypass "snapd" || return 1
            ;;
        *)
            install_pm_pkg_bypass "snapd" || return 1
            ;;
    esac

    configure_snap
}

install_waydroid() {
    detect_system
    case "$primary_pm" in
        apt)
            sudo apt-get install -y curl ca-certificates
            curl -s https://repo.waydro.id | sudo bash
            ;;
        xbps)
            sudo xbps-install -Sy python3-pyclip wl-clipboard
            ;;
    esac

    install_pm_pkg_bypass "waydroid" || return 1

    configure_waydroid
}
