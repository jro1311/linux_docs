# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

red_message() {
    local label="$1"
    local value="${2:-}"
    echo "${red}$label${reset} $value" >&2
}

green_message() {
    local label="$1"
    local value="${2:-}"
    echo "${green}$label${reset} $value" >&2
}

yellow_message() {
    local label="$1"
    local value="${2:-}"
    echo "${yellow}$label${reset} $value" >&2
}

blue_message() {
    local label="$1"
    local value="${2:-}"
    echo "${blue}$label${reset} $value" >&2
}

print_field() {
    assert_arity "$#" eq 2 "<label> <value>" || return 1
    detect_system

    local label="$1"
    local var="$2"

    if [ -z "$var" ] || [ "$var" = 0 ]; then
        return 0
    fi

    green_message "$label:" "$var"
}

confirm_proceed() {
    read -r -p "Press ${green}ENTER${reset} to proceed or ${red}CTRL+C${reset} to cancel: "
}

confirm() {
    local prompt="$1"
    local answer default

    if [ -z "$prompt" ]; then
        prompt="Confirm? [y/N]"
    fi

    case "$prompt" in
        *"[Y/n]"*) default="y" ;;
        *"[y/N]"*) default="n" ;;
        *) default="n" ;;
    esac

    while true; do
        read -r -p "$prompt: " answer
        answer="${answer:-$default}"

        case "$answer" in
            [Yy]) return 0 ;;
            [Nn]) return 1 ;;
            *) continue ;;
        esac
    done
}

format_bytes() {
    bytes=$1

    if [ "$bytes" -ge $((1024*1024*1024)) ]; then
        value=$(awk "BEGIN { printf \"%.1f\", $bytes / (1024*1024*1024) }")
        units="GiB"

    elif [ "$bytes" -ge $((1024*1024)) ]; then
        value=$(awk "BEGIN { printf \"%.1f\", $bytes / (1024*1024) }")
        units="MiB"

    else
        value=$(awk "BEGIN { printf \"%.1f\", $bytes / 1024 }")
        units="KiB"
    fi

    printf "%s %s" "$value" "$units"
}
