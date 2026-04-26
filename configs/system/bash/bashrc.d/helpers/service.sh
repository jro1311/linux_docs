# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

enable_service() {
    assert_arity "$#" ge 1 "<service>" || return 1
    detect_system

    for service in "$@"; do
        case "$init_system" in
            systemd)
                sudo systemctl enable --now "$service" || return 1
                ;;
            dinit)
                local svc="/etc/dinit.d/$service"
                local target="/etc/dinit.d/boot.d/$service"

                if [ ! -e "$svc" ]; then
                    red_message "$init_system:" "'$service' not found under /etc/dinit.d."
                    return 1
                fi

                if [ ! -L "$target" ]; then
                    sudo ln -s "$svc" "$target" || return 1
                fi

                sudo dinitctl start "$service" || return 1
                ;;
            openrc)
                sudo rc-update add "$service" || return 1
                sudo rc-service "$service" start || return 1
                ;;
            runit)
                local svc="/etc/sv/$service"
                local target="/var/service/$service"

                if [ ! -d "$svc" ]; then
                    red_message "$init_system:" "'$service' not found under /etc/sv."
                    return 1
                fi

                if [ ! -L "$target" ]; then
                    sudo ln -s "$svc" "$target" || return 1
                fi
                ;;
            s6)
                local svc="/etc/s6/sv/$service"
                local target="/var/service/$service"

                if [ ! -d "$svc" ]; then
                    red_message "$init_system:" "'$service' not found under /etc/s6/sv."
                    return 1
                fi

                if [ ! -L "$target" ]; then
                    sudo ln -s "$svc" "$target" || return 1
                fi
                ;;
            sysvinit)
                sudo update-rc.d "$service" enable || sudo update-rc.d "$service" defaults || return 1
                sudo service "$service" start || return 1
                ;;
            *)
                unsupported_init_system
                return 1
                ;;
        esac
    done
}

disable_service() {
    assert_arity "$#" ge 1 "<service>" || return 1
    detect_system

    for service in "$@"; do
        case "$init_system" in
            systemd)
                sudo systemctl disable --now "$service" || return 1
                ;;
            dinit)
                local target="/etc/dinit.d/boot.d/$service"

                if [ ! -L "$target" ]; then
                    red_message "$init_system:" "'$service' is not enabled (missing $target)."
                    return 1
                fi

                sudo rm "$target" || return 1
                sudo dinitctl stop "$service" || return 1
                ;;
            openrc)
                sudo rc-update del "$service" || return 1
                sudo rc-service "$service" stop || return 1
                ;;
            runit)
                local target="/var/service/$service"

                if [ ! -d "$target" ]; then
                    red_message "$init_system:" "'$service' is not enabled (missing $target)."
                    return 1
                fi

                sudo rm "$target" || return 1
                ;;
            s6)
                local target="/var/service/$service"

                if [ ! -d "$target" ]; then
                    red_message "$init_system:" "'$service' is not enabled (missing $target)."
                    return 1
                fi

                sudo rm "$target" || return 1
                ;;
            sysvinit)
                sudo update-rc.d "$service" disable || sudo update-rc.d "$service" remove || return 1
                sudo service "$service" stop || return 1
                ;;
            *)
                unsupported_init_system
                return 1
                ;;
        esac
    done
}

start_service() {
    assert_arity "$#" ge 1 "<service>" || return 1
    detect_system

    for service in "$@"; do
        case "$init_system" in
            systemd)
                sudo systemctl start "$service" || return 1
                ;;
            dinit)
                sudo dinitctl start "$service" || return 1
                ;;
            openrc)
                sudo rc-service "$service" start || return 1
                ;;
            runit)
                local target="/var/service/$service"

                if [ ! -d "$target" ]; then
                    red_message "$init_system:" "'$service' is not enabled (missing $target)."
                    return 1
                fi

                sudo sv start "$service" || return 1
                ;;
            s6)
                local target="/var/service/$service"

                if [ ! -d "$target" ]; then
                    red_message "$init_system:" "'$service' is not enabled (missing $target)."
                    return 1
                fi

                sudo s6-svc -u "$target" || return 1
                ;;
            sysvinit)
                sudo service "$service" start || return 1
                ;;
            *)
                unsupported_init_system
                return 1
                ;;
        esac
    done
}

stop_service() {
    assert_arity "$#" ge 1 "<service>" || return 1
    detect_system

    for service in "$@"; do
        case "$init_system" in
            systemd)
                sudo systemctl stop "$service" || return 1
                ;;
            dinit)
                sudo dinitctl stop "$service" || return 1
                ;;
            openrc)
                sudo rc-service "$service" stop || return 1
                ;;
            runit)
                local target="/var/service/$service"

                if [ ! -d "$target" ]; then
                    red_message "$init_system:" "'$service' is not enabled (missing $target)."
                    return 1
                fi

                sudo sv stop "$service" || return 1
                ;;
            s6)
                local target="/var/service/$service"

                if [ ! -d "$target" ]; then
                    red_message "$init_system:" "'$service' is not enabled (missing $target)."
                    return 1
                fi

                sudo s6-svc -d "$target" || return 1
                ;;
            sysvinit)
                sudo service "$service" stop || return 1
                ;;
            *)
                unsupported_init_system
                return 1
                ;;
        esac
    done
}

restart_service() {
    assert_arity "$#" ge 1 "<service>" || return 1
    detect_system

    for service in "$@"; do
        case "$init_system" in
            systemd)
                sudo systemctl restart "$service" || return 1
                ;;
            dinit)
                sudo dinitctl restart "$service" || return 1
                ;;
            openrc)
                sudo rc-service "$service" restart || return 1
                ;;
            runit)
                local target="/var/service/$service"

                if [ ! -d "$target" ]; then
                    red_message "$init_system:" "'$service' is not enabled (missing $target)."
                    return 1
                fi

                sudo sv restart "$service" || return 1
                ;;
            s6)
                local target="/var/service/$service"

                if [ ! -d "$target" ]; then
                    red_message "$init_system:" "'$service' is not enabled (missing $target)."
                    return 1
                fi

                sudo s6-svc -r "$target" || return 1
                ;;
            sysvinit)
                sudo service "$service" restart || return 1
                ;;
            *)
                unsupported_init_system
                return 1
                ;;
        esac
    done
}

status_service() {
    assert_arity "$#" ge 1 "<service>" || return 1
    detect_system

    for service in "$@"; do
        case "$init_system" in
            systemd)
                sudo systemctl status "$service" || return 1
                ;;
            dinit)
                sudo dinitctl status "$service" || return 1
                ;;
            openrc)
                sudo rc-service "$service" status || return 1
                ;;
            runit)
                local target="/var/service/$service"

                if [ ! -d "$target" ]; then
                    red_message "$init_system:" "'$service' is not enabled (missing $target)."
                    return 1
                fi

                sudo sv status "$service" || return 1
                ;;
            s6)
                local target="/var/service/$service"

                if [ ! -d "$target" ]; then
                    red_message "$init_system:" "'$service' is not enabled (missing $target)."
                    return 1
                fi

                sudo s6-svstat "$target" || return 1
                ;;
            sysvinit)
                sudo service "$service" status || return 1
                ;;
            *)
                unsupported_init_system
                return 1
                ;;
        esac
    done
}
