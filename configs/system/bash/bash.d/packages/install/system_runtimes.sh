# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

install_tlp() {
    detect_system
    ensure_pkg "tlp" || return 1

    if [ "$flatpak_installed" -eq 1 ] && confirm "Install GUI application for TLP? [y/N]"; then
        install_flatpak_pkg_bypass "com.github.d4nj1.tlpui" || return 1
    fi

    configure_tlp || return 1
}

install_zram() {
    detect_system
    case "$init_system" in
        systemd)
            ensure_pkg "zram-generator"
            ;;

        dinit|openrc|runit|s6|sysvinit)
            if [ "$primary_pm" = "xbps" ]; then
                ensure_pkg "zram-generator"
            fi
            ;;
        *)
            unsupported_init_system
            return 1
            ;;
    esac
}

