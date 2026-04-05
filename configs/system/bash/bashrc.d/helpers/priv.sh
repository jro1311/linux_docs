# shellcheck shell=bash
# shellcheck source=/dev/null
# shellcheck disable=SC2034,SC2154

sudo_run() {
    if "$@" >/dev/null 2>&1; then
        return 0
    fi

    local ec=$?

    if [ "$(id -u)" -eq 0 ]; then
        return "$ec"
    fi

    case "$ec" in
        "13"|"126")
            sudo "$@" >/dev/null 2>&1
            return $?
            ;;
    esac

    return "$ec"
}

sudo_run_passthrough() {
    if "$@" 2>/dev/null; then
        return 0
    fi

    local ec=$?

    if [ "$(id -u)" -eq 0 ]; then
        return "$ec"
    fi

    case "$ec" in
        "13"|"126")
            sudo "$@" 2>/dev/null
            return $?
            ;;
    esac

    return "$ec"
}

sudo_run_verbose() {
    if "$@"; then
        return 0
    fi

    local ec=$?

    if [ "$(id -u)" -eq 0 ]; then
        return "$ec"
    fi

    case "$ec" in
        "13"|"126")
            sudo "$@"
            return $?
            ;;
    esac

    return "$ec"
}
