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

apply_utf16_substitutions() {
    assert_arity "$#" "ge" 2 "<filename> <patterns>" || return 1

    local file="$1"
    shift
    local patterns=("$@")

    # Converts file to utf8, makes changes, then converts it back
    local tmp="${file}.utf8"

    iconv -f utf-16le -t utf-8 "$file" > "$tmp"

    for pattern in "${patterns[@]}"; do
        sed -i "$pattern" "$tmp"
    done

    iconv -f utf-8 -t utf-16le "$tmp" > "$file"
    rm -f "$tmp"
}
