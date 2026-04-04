sudo_run() {
    if [ "$#" -eq 0 ]; then
        red_message "sudo_run_passthrough:" "Expected at least 1 argument, got $#."
        return 1
    fi

    if "$@" >/dev/null 2>&1; then
        return 0
    elif sudo "$@" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

sudo_run_passthrough() {
    if [ "$#" -eq 0 ]; then
        red_message "sudo_run_passthrough:" "Expected at least 1 argument, got $#."
        return 1
    fi

    if "$@"; then
        return 0
    elif sudo "$@"; then
        return 0
    else
        return 1
    fi
}
