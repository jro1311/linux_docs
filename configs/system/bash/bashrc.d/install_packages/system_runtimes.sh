# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

install_tlp() {
    detect_system
    install_pm_pkg_bypass "tlp" || return 1

    if [ "$flatpak_installed" -eq 1 ]; then
        install_flatpak_pkg_bypass "com.github.d4nj1.tlpui"
    fi

    configure_tlp
}

install_zram() {
    detect_system
    case "$init_system" in
        systemd)
            install_pm_pkg_bypass "${zram_pkg[$primary_pm]}"
            ;;
        dinit|openrc|runit|s6|sysvinit)
            if [ "$primary_pm" = "xbps" ]; then
                install_pm_pkg_bypass "${zram_pkg[$primary_pm]}"
            fi
            ;;
        *)
            unsupported_init_system
            return 1
            ;;
    esac
}

