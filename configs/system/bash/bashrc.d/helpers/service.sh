# shellcheck shell=bash
# shellcheck source=/dev/null
# shellcheck disable=SC2034,SC2154

enable_service() {
    if [ "$#" -eq 0 ]; then
        red_message "enable_service:" "Expected 1 argument, got $#."
        return 1
    fi

    detect_system
    local service="$1"

    case "$init_system" in
        "systemd")
            sudo systemctl enable --now "$service"
            ;;
        "dinit")
            local svc="/etc/dinit.d/$service"
            local target="/etc/dinit.d/boot.d/$service"

            if [ ! -e "$svc" ]; then
                red_message "$init_system:" "'$service' not found under /etc/dinit.d."
                return 1
            fi

            if [ ! -L "$target" ]; then
                sudo ln -s "$svc" "$target"
            fi

            sudo dinitctl start "$service"
            ;;
        "openrc")
            sudo rc-update add "$service"
            sudo rc-service "$service" start
            ;;
        "runit")
            local svc="/etc/sv/$service"
            local target="/var/service/$service"

            if [ ! -d "$svc" ]; then
                red_message "$init_system:" "'$service' not found under /etc/sv."
                return 1
            fi

            if [ ! -L "$target" ]; then
                sudo ln -s "$svc" "$target"
            fi
            ;;
        "s6")
            local svc="/etc/s6/sv/$service"
            local target="/var/service/$service"

            if [ ! -d "$svc" ]; then
                red_message "$init_system:" "'$service' not found under /etc/s6/sv."
                return 1
            fi

            if [ ! -L "$target" ]; then
                sudo ln -s "$svc" "$target"
            fi
            ;;
        "sysvinit")
            sudo update-rc.d "$service" enable || sudo update-rc.d "$service" defaults
            sudo service "$service" start
            ;;
        *)
            unsupported_init_system
            return 1
            ;;
    esac
}

disable_service() {
    if [ "$#" -eq 0 ]; then
        red_message "disable_service:" "Expected at least 1 argument, got $#."
        return 1
    fi

    detect_system
    local service="$1"

    case "$init_system" in
        "systemd")
            sudo systemctl disable --now "$service"
            ;;
        "dinit")
            local target="/etc/dinit.d/boot.d/$service"

            if [ ! -L "$target" ]; then
                red_message "$init_system:" "'$service' is not enabled (missing $target)."
                return 1
            fi

            sudo rm "$target"
            sudo dinitctl stop "$service"
            ;;
        "openrc")
            sudo rc-update del "$service"
            sudo rc-service "$service" stop
            ;;
        "runit")
            local target="/var/service/$service"

            if [ ! -d "$target" ]; then
                red_message "$init_system:" "'$service' is not enabled (missing $target)."
                return 1
            fi

            sudo rm -v "$target"
            ;;
        "s6")
            local target="/var/service/$service"

            if [ ! -d "$target" ]; then
                red_message "$init_system:" "'$service' is not enabled (missing $target)."
                return 1
            fi

            sudo rm -v "$target"
            ;;
        "sysvinit")
            sudo update-rc.d "$service" disable || sudo update-rc.d "$service" remove
            sudo service "$service" stop
            ;;
        *)
            unsupported_init_system
            return 1
            ;;
    esac
}

start_service() {
    if [ "$#" -eq 0 ]; then
        red_message "start_service:" "Expected 1 argument, got $#."
        return 1
    fi

    detect_system
    local service="$1"

    case "$init_system" in
        "systemd")
            sudo systemctl start "$service"
            ;;
        "dinit")
            sudo dinitctl start "$service"
            ;;
        "openrc")
            sudo rc-service "$service" start
            ;;
        "runit")
            local target="/var/service/$service"

            if [ ! -d "$target" ]; then
                red_message "$init_system:" "'$service' is not enabled (missing $target)."
                return 1
            fi

            sudo sv start "$service"
            ;;
        "s6")
            local target="/var/service/$service"

            if [ ! -d "$target" ]; then
                red_message "$init_system:" "'$service' is not enabled (missing $target)."
                return 1
            fi

            sudo s6-svc -u "$target"
            ;;
        "sysvinit")
            sudo service "$service" start
            ;;
        *)
            unsupported_init_system
            return 1
            ;;
    esac
}

stop_service() {
    if [ "$#" -eq 0 ]; then
        red_message "stop_service:" "Expected at least 1 argument, got $#."
        return 1
    fi

    detect_system
    local service="$1"

    case "$init_system" in
        "systemd")
            sudo systemctl stop "$service"
            ;;
        "dinit")
            sudo dinitctl stop "$service"
            ;;
        "openrc")
            sudo rc-service "$service" stop
            ;;
        "runit")
            local target="/var/service/$service"

            if [ ! -d "$target" ]; then
                red_message "$init_system:" "'$service' is not enabled (missing $target)."
                return 1
            fi

            sudo sv stop "$service"
            ;;
        "s6")
            local target="/var/service/$service"

            if [ ! -d "$target" ]; then
                red_message "$init_system:" "'$service' is not enabled (missing $target)."
                return 1
            fi

            sudo s6-svc -d "$target"
            ;;
        "sysvinit")
            sudo service "$service" stop
            ;;
        *)
            unsupported_init_system
            return 1
            ;;
    esac
}

restart_service() {
    if [ "$#" -eq 0 ]; then
        red_message "restart_service:" "Expected 1 argument, got $#."
        return 1
    fi

    detect_system
    local service="$1"

    case "$init_system" in
        "systemd")
            sudo systemctl restart "$service"
            ;;
        "dinit")
            sudo dinitctl restart "$service"
            ;;
        "openrc")
            sudo rc-service "$service" restart
            ;;
        "runit")
            local target="/var/service/$service"

            if [ ! -d "$target" ]; then
                red_message "$init_system:" "'$service' is not enabled (missing $target)."
                return 1
            fi

            sudo sv restart "$service"
            ;;
        "s6")
            local target="/var/service/$service"

            if [ ! -d "$target" ]; then
                red_message "$init_system:" "'$service' is not enabled (missing $target)."
                return 1
            fi

            sudo s6-svc -r "$target"
            ;;
        "sysvinit")
            sudo service "$service" restart
            ;;
        *)
            unsupported_init_system
            return 1
            ;;
    esac
}

status_service() {
    if [ "$#" -eq 0 ]; then
        red_message "status_service:" "Expected 1 argument, got $#."
        return 1
    fi

    detect_system
    local service="$1"

    case "$init_system" in
        "systemd")
            sudo systemctl status "$service"
            ;;
        "dinit")
            sudo dinitctl status "$service"
            ;;
        "openrc")
            sudo rc-service "$service" status
            ;;
        "runit")
            local target="/var/service/$service"

            if [ ! -d "$target" ]; then
                red_message "$init_system:" "'$service' is not enabled (missing $target)."
                return 1
            fi

            sudo sv status "$service"
            ;;
        "s6")
            local target="/var/service/$service"

            if [ ! -d "$target" ]; then
                red_message "$init_system:" "'$service' is not enabled (missing $target)."
                return 1
            fi

            sudo s6-svstat "$target"
            ;;
        "sysvinit")
            sudo service "$service" status
            ;;
        *)
            unsupported_init_system
            return 1
            ;;
    esac
}
