# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

assert_arity() {
    case "$2" in
        eq|ge|le|any)
            if [ "$#" -ne 4 ]; then
                red_message "assert_arity:" "expected 4 argument(s) <actual> <mode> <needed> <signature>"
                return 1
            fi
            ;;
        range)
            if [ "$#" -ne 5 ]; then
                red_message "assert_arity:" "expected 5 argument(s) <actual> range <min> <max> <signature>"
                return 1
            fi
            ;;
        *)
            red_message "assert_arity:" "invalid mode '$2'"
            return 1
            ;;
    esac

    local actual="$1"
    local mode="$2"
    local value="$3"
    local min="$3"
    local max="${4-}"
    local signature="${5-}"

    local caller="${FUNCNAME[1]}"

    case "$mode" in
        eq)
            if [ "$actual" -ne "$value" ]; then
                red_message "${caller}:" "expected $value argument(s) $signature"
                return 1
            fi
            ;;
        ge)
            if [ "$actual" -lt "$value" ]; then
                red_message "${caller}:" "expected min $value argument(s) $signature"
                return 1
            fi
            ;;
        le)
            if [ "$actual" -gt "$value" ]; then
                red_message "${caller}:" "expected max $value argument(s) $signature"
                return 1
            fi
            ;;
        range)
            if [ "$actual" -lt "$min" ] || [ "$actual" -gt "$max" ]; then
                red_message "${caller}:" "expected $min to $max argument(s) $signature"
                return 1
            fi
            ;;
        any)
            ;;
    esac
}

copy_config() {
    assert_arity "$#" "eq" 3 "<overwrite_flag> <source> <target>" || return 1

    local overwrite="$1"
    local source="$2"
    local target="$3"

    if [ "$overwrite" -eq 1 ] || [ ! -f "$target" ]; then
        mkdir -p "$(dirname "$target")"
        rm -f "$target"
        cp "$source" "$target"
    fi
}

copy_config_dir() {
    assert_arity "$#" "eq" 3 "<overwrite_flag> <source> <target>" || return 1

    local overwrite="$1"
    local source="$2"
    local target_parent="$3"

    local name
    name="$(basename "$source")"
    local target="${target_parent}/${name}"

    if [ "$overwrite" -eq 1 ] || [ ! -d "$target" ]; then
        rm -rf "$target"
        mkdir -p "$target_parent"
        cp -r "$source" "$target"
    fi
}

copy_sys_config() {
    assert_arity "$#" "eq" 3 "<overwrite_flag> <source> <target>" || return 1

    local overwrite="$1"
    local source="$2"
    local target="$3"

    if [ "$overwrite" -eq 1 ] || [ ! -f "$target" ]; then
        sudo rm -f "$target"
        sudo mkdir -p "$(dirname "$target")"
        sudo cp "$source" "$target"
    fi
}

copy_sys_config_dir() {
    assert_arity "$#" "eq" 3 "<overwrite_flag> <source> <target>" || return 1

    local overwrite="$1"
    local source="$2"
    local target_parent="$3"

    local name
    name="$(basename "$source")"
    local target="${target_parent}/${name}"

    if [ "$overwrite" -eq 1 ] || [ ! -d "$target" ]; then
        sudo rm -rf "$target"
        sudo mkdir -p "$target_parent"
        sudo cp -r "$source" "$target"
    fi
}

match_sha256() {
    local iso="$1"
    local expected="$2"
    local actual

    actual="$(sha256sum "$iso" | awk '{print $1}')"

    if [ "$actual" = "$expected" ]; then
        green_message "Success:" "Checksum match."
        return 0
    else
        red_message "Error:" "Checksum mismatch."
        return 1
    fi
}

in_array() {
    local needle=$1
    shift

    for item in "$@"; do
        [ "$item" = "$needle" ] && return 0
    done
    return 1
}

strip_trailing_slash() {
    case "$1" in
        */) printf '%s\n' "${1%/}" ;;
        *)  printf '%s\n' "$1" ;;
    esac
}

apply_utf16_substitutions() {
    assert_arity "$#" "ge" 2 "<filename> <patterns>" || return 1

    local file="$1"
    shift
    local patterns=("$@")

    # Converts file to utf8, makes changes, then converts it back
    local tmp="${file}.utf8"

    iconv -f utf-16le -t utf-8 "$file" > "$tmp" || return 1

    for pattern in "${patterns[@]}"; do
        sed -i "$pattern" "$tmp" || return 1
    done

    iconv -f utf-8 -t utf-16le "$tmp" > "$file" || return 1
    rm -f "$tmp" || return 1
}
