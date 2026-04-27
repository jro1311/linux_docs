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

collect_text_files() {
    local target_dir="$1"
    local -n export_array="$2"

    target_dir="${target_dir%/}"

    local include_exts=(
        txt md conf cfg ini json yaml yml toml
        sh bash zsh
        js ts css html xml
        py rb lua
        c h cpp go rs
        csv tsv env properties
        dockerfile gitignore gitattributes
        mk
    )

    local find_args=()
    for ext in "${include_exts[@]}"; do
        find_args+=( -iname "*.${ext}" -o )
    done
    unset 'find_args[${#find_args[@]}-1]'

    local ext_files=()
    mapfile -t ext_files < <(
        find "$target_dir" \
            -path "*/.git" -prune -o \
            -type f \( "${find_args[@]}" \) -print
    )

    local noext_files=()
    if command -v file >/dev/null 2>&1; then
        mapfile -t noext_files < <(
            find "$target_dir" \
                -path "*/.git" -prune -o \
                -type f -not -name "*.*" -print0 |
            xargs -0 -r file --mime-type |
            awk -F: '$2 ~ /text\// {print $1}'
        )
    else
        yellow_message "Skipped:" "Extensionless files (no 'file' utility available)."
    fi

    export_array=( "${ext_files[@]}" "${noext_files[@]}" )
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
