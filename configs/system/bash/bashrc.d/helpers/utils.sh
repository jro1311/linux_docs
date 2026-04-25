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

enable_strict_mode() {
    set -euo pipefail
}

disable_strict_mode() {
    set +euo pipefail
}

enable_debug_mode() {
    set -vx
}

disable_debug_mode() {
    set +vx
}

check() {
    local cmd="$1"
    shift
    if command -v "$cmd" >/dev/null 2>&1; then
        "$@"
    fi
}

check_flatpak() {
    local pkg="$1"
    shift
    if flatpak info "$pkg"  >/dev/null 2>&1; then
        "$@"
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

run_script() {
    assert_arity "$#" "ge" 1 "<filename>" || return 1

    local status=0

    for script in "$@"; do
        if [ ! -f "$script" ]; then
            red_message "Error:" "'$script' does not exist."
            status=1
            continue
        fi

        chmod +x "$script"
        "$script" || status=1
    done

    return "$status"
}

copy_config() {
    assert_arity "$#" "eq" 2 "<source> <target_dir>" || return 1
    detect_system

    local source="$1"
    local target_dir="$2"

    if [ ! -e "$source" ]; then
        red_message "Error:" "'$source' does not exist."
        return 1
    fi

    sudo mkdir -pv "$target_dir"

    if sudo cp -rv "$source" "$target_dir"; then
        green_message "Success:" "$target_dir"
        return 0
    else
        red_message "Failure:" "$target_dir"
        return 1
    fi
}

create_autostart_entry() {
    assert_arity "$#" "range" 1 2 "<name> <exec>" || return 1

    local name="$1"
    local exec="${2:-}"

    mkdir -pv "$HOME/.config/autostart"

    if [ ! -f "$HOME/.config/autostart/$name.desktop" ] ;then
        cat > "$HOME/.config/autostart/$name.desktop" <<-EOF
[Desktop Entry]
Type=Application
Name=$name
Exec=$exec
EOF
    else
        green_message "Autostart entry already exists:" "$name"
        return 0
    fi

    green_message "Autostart entry created:" "$name"
}

input_directory() {
    local prompt="$1"
    local default="${2:-}"
    local dir

    while true; do
        read -er -p "$prompt: " dir
        dir=${dir:-$default}

        # Normalizes environment variables to absolute paths
        dir="${dir/#~/$HOME}"
        dir="${dir/#\$HOME/$HOME}"
        dir="${dir/#\$LD_ROOT/$LD_ROOT}"
        dir="${dir/#\$LD_CFG/$LD_CFG}"
        dir="${dir/#\$LD_DOC/$LD_DOC}"
        dir="${dir/#\$LD_HELP/$LD_HELP}"
        dir="${dir/#\$LD_SCR/$LD_SCR}"
        dir="${dir/#\$LD_SS/$LD_SS}"
        dir="${dir/#\$LD_BASHD/$LD_BASHD}"
        dir="${dir/#\$LD_BASH/$LD_BASH}"
        dir="${dir/#\$LBK1/$LBK1}"
        dir="${dir/#\$LBK2/$LBK2}"

        if [ ! -d "$dir" ]; then
            red_message "Error:" "'$dir' does not exist."
            continue
        fi

        printf '%s\n' "$dir"
        break
    done
}

input_positive_integer() {
    local label="$1"
    local num

    while true; do
        read -r -p "Enter $label: " num

        case "$num" in
            "")
                red_message "Error:" "No number provided."
                continue
                ;;
            *[!0-9]*)
                red_message "Error:" "Number must be a non-negative integer."
                continue
                ;;
            "0")
                red_message "Error:" "Number cannot be 0."
                continue
                ;;
        esac

        printf '%s\n' "$num"
        return 0
    done
}

append_text() {
    assert_arity "$#" "eq" 2 "<text> <filename>" || return 1

    local input_text="$1"
    local filename="$2"

    if echo "$input_text" | sudo_run tee -a "$filename" >/dev/null 2>&1; then
        green_message "Success:" "'$input_text' appended to '$filename'."
    else
        red_message "Error:" "Failed to append text to '$filename'."
        return 1
    fi
}

prepend_text() {
    assert_arity "$#" "eq" 2 "<text> <filename>" || return 1

    local input_text="$1"
    local filename="$2"
    local temp_file

    temp_file=$(mktemp) || return 1

    if ! sudo_run_passthrough sh -c \
        "{ printf '%s\n' \"$input_text\"; cat \"$filename\"; }" >"$temp_file"; then
        red_message "Error:" "Failed to create temporary file for '$filename'."
        rm -f "$temp_file"
        return 1
    fi

    if sudo_run command install -m "$(stat -c %a "$filename")" \
            --owner="$(stat -c %U "$filename")" \
            --group="$(stat -c %G "$filename")" \
            "$temp_file" "$filename"; then
        rm -f "$temp_file"
        green_message "Success:" "'$input_text' prepended to '$filename'."
    else
        red_message "Error:" "Failed to prepend text to '$filename'."
        rm -f "$temp_file"
        return 1
    fi
}

remove_text() {
    assert_arity "$#" "eq" 2 "<text> <filename>" || return 1

    local input_text="$1"
    local filename="$2"

    if sudo_run sed -i "s/${input_text}//g" "$filename" 2>/dev/null; then
        green_message "Success:" "'$input_text' removed from '$filename'."
    else
        red_message "Error:" "Failed to remove text from '$filename'."
        return 1
    fi
}

trim_trailing_blanks() {
    assert_arity "$#" "eq" 1 "<filename>" || return 1

    local filename="$1"

    # shellcheck disable=SC2016
    if sudo_run sed -i ':a;/^[[:space:]]*$/{$d;N;ba}' "$filename"; then
        green_message "Success:" "Trimmed trailing blanks from '$filename'."
    else
        red_message "Error:" "Failed to trim trailing blanks from '$filename'."
        return 1
    fi
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

_kernel_parameter_exists() {
    local karg="$1"

    case "$primary_pm" in
        rpm-ostree)
            rpm-ostree kargs | grep -Fq "$karg"
            ;;
        *)
            case "$bootloader" in
                "grub")
                    grep -Fq "$karg" /etc/default/grub
                    ;;
                "limine")
                    grep -Fq "$karg" /etc/default/limine
                    ;;
                *)
                    unsupported_bootloader
                    return 1
            esac
            ;;
    esac
}

_kernel_parameter_append() {
    local karg="$1"

    case "$primary_pm" in
        rpm-ostree)
            sudo rpm-ostree kargs --append="$karg"
            ;;
        *)
            case "$bootloader" in
                "grub")
                    sudo sed -i "s/\(GRUB_CMDLINE_LINUX=\"[^\"]*\)\"/\1 $karg\"/" /etc/default/grub
                    ;;
                "limine")
                    sudo sed -i "/^KERNEL_CMDLINE\[default\\]/ s/\"$/ $karg\"/" /etc/default/limine
                    ;;
                *)
                    unsupported_bootloader
                    return 1
            esac
            ;;
    esac
}

add_kernel_parameter() {
    assert_arity "$#" "ge" 1 "<parameter>" || return 1
    detect_system

    local updated=0

    for karg in "$@"; do
        if _kernel_parameter_exists "$karg"; then
            green_message "Kernel parameter already present:" "'$karg'"
            continue
        fi

        if _kernel_parameter_append "$karg"; then
            green_message "Success:" "'$karg' added to kernel parameters."
            updated=1
        else
            red_message "Error:" "Failed to add '$karg'."
            return 1
        fi
    done

    if [ "$updated" -eq 1 ] && [ "$primary_pm" != "rpm-ostree" ]; then
        update_bootloader
    fi
}

_kernel_parameter_delete() {
    local karg="$1"

    case "$primary_pm" in
        rpm-ostree)
            sudo rpm-ostree kargs --delete="$karg"
            ;;
        *)
            case "$bootloader" in
                "grub")
                    sudo sed -i -e "s/$karg//g" -e 's/ *"$/"/' /etc/default/grub
                    ;;
                "limine")
                    sudo sed -i -e "s/$karg//g" -e 's/ *"$/"/' /etc/default/limine
                    ;;
                *)
                    unsupported_bootloader
                    return 1
            esac
            ;;
    esac
}

remove_kernel_parameter() {
    assert_arity "$#" "ge" 1 "<parameter>" || return 1
    detect_system

    local updated=0

    for karg in "$@"; do
        if ! _kernel_parameter_exists "$karg"; then
            green_message "Kernel parameter already not present:" "'$karg'"
            continue
        fi

        if _kernel_parameter_delete "$karg"; then
            green_message "Success:" "'$karg' removed from kernel parameters."
            updated=1
        else
            red_message "Error:" "Failed to remove '$karg'."
            return 1
        fi
    done

    if [ "$updated" -eq 1 ] && [ "$primary_pm" != "rpm-ostree" ]; then
        update_bootloader
    fi
}
