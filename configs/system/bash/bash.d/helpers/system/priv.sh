# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

sudo_run() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
        return $?
    fi

    local captured_stderr
    captured_stderr="$("$@" 2>&1 >/dev/null)"
    local ec=$?

    if [ "$ec" -eq 0 ] && [ -z "$captured_stderr" ]; then
        return 0
    fi

    sudo "$@"
}

sudo_run_passthrough() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
        return $?
    fi

    if "$@"; then
        return 0
    fi

    sudo "$@"
}

sudo_run_verbose() {
    if [ "$(id -u)" -eq 0 ]; then
        blue_message "MODE:" "RUNNING AS SUPERUSER"
        "$@"
        return $?
    fi

    if "$@"; then
        return 0
    fi

    blue_message "MODE:" "RUNNING AS SUPERUSER"
    sudo "$@"
}
