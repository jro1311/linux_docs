# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

install_zram() {
    detect_system

    case "$init_system" in
        systemd)
            ensure_pkg "zram-generator"
            ;;

        *)
            if [ "$primary_pm" = "xbps" ]; then
                ensure_pkg "zram-generator"
            fi
            ;;
    esac
}

