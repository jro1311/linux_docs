# shellcheck shell=bash
# shellcheck source=/dev/null
# shellcheck disable=SC2034,SC2154,SC2016

enable_strict_mode() { set -euo pipefail; }
disable_strict_mode() { set +euo pipefail; }
enable_debug_mode() { set -vx; }
disable_debug_mode() { set +vx; }

check() {
    local cmd="$1"
    shift
    if command -v "$cmd" >/dev/null 2>&1; then
        "$@"
    fi
}

inverse_check() {
    local cmd="$1"
    shift
    if ! command -v "$cmd" >/dev/null 2>&1; then
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

inverse_check_flatpak() {
    local pkg="$1"
    shift
    if ! flatpak info "$pkg"  >/dev/null 2>&1; then
        "$@"
    fi
}

install_packages() {
    local packages=("$@")
    if [ ${#packages[@]} -eq 0 ]; then
        return 0
    fi

    detect_system
    case "$primary_pm" in
        "apt")
            sudo apt-get install -y "${packages[@]}"
            ;;
        "dnf")
            sudo dnf install -y "${packages[@]}"
            ;;
        "eopkg")
            sudo eopkg install -y "${packages[@]}"
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm "${packages[@]}"
            ;;
        "xbps")
            sudo xbps-install -Sy "${packages[@]}"
            ;;
        "zypper")
            sudo zypper in -y "${packages[@]}"
            ;;
        "rpm-ostree")
            for package in "${packages[@]}"; do
                sudo rpm-ostree install "$package" || true
            done
            ;;
        *)
            unsupported_package_manager
            return 1
            ;;
    esac
}

remove_packages() {
    local packages=("$@")
    if [ ${#packages[@]} -eq 0 ]; then
        return 0
    fi

    detect_system
    case "$primary_pm" in
        "apt")
            sudo apt-get remove -y "${packages[@]}"
            ;;
        "dnf")
            sudo dnf remove -y "${packages[@]}"
            ;;
        "eopkg")
            sudo eopkg remove -y "${packages[@]}"
            ;;
        "pacman")
            sudo pacman -Rs --noconfirm "${packages[@]}"
            ;;
        "xbps")
            sudo xbps-remove -Ry "${packages[@]}"
            ;;
        "zypper")
            sudo zypper rm --clean-deps -y "${packages[@]}"
            ;;
        "rpm-ostree")
            for package in "${packages[@]}"; do
                sudo rpm-ostree remove "$package" || true
            done
            ;;
        *)
            unsupported_package_manager
            return 1
            ;;
    esac
}

sync_config() {
    if [ "$#" -ne 2 ]; then
        red_message "sync_config:" "Expected 2 arguments, got $#."
        return 1
    fi

    local source="$1"
    local target_dir="$2"

    if [ ! -e "$source" ]; then
        red_message "Error:" "'$source' does not exist."
        return 1
    fi

    sudo_run_passthrough mkdir -pv "$target_dir"

    if sudo_run_passthrough rsync -auhv --progress "$source" "$target_dir"; then
        green_message "Success:" "$target_dir"
        return 0
    else
        red_message "Failure:" "$target_dir"
        return 1
    fi
}

find_text() {
    if [ "$#" -ne 2 ]; then
        red_message "find_text:" "Expected 2 arguments, got $#."
        return 1
    fi

    local text="$1"
    local target_dir="$2"

    export -f green_message
    export green reset

    include_exts=(
        txt md conf cfg ini json yaml yml toml
        sh bash zsh
        js ts css html xml
        py rb lua
        c h cpp go rs
        csv tsv env properties
        dockerfile gitignore gitattributes
        mk
    )

    find_args=()

    for ext in "${include_exts[@]}"; do
        find_args+=( -iname "*.${ext}" -o )
    done

    unset 'find_args[${#find_args[@]}-1]'

    mapfile -t ext_files < <(
        find "$target_dir" -type f \( "${find_args[@]}" \) -print
    )

    noext_files=()

    if command -v file >/dev/null 2>&1; then
        mapfile -t noext_files < <(
            find "$target_dir" -type f -not -name "*.*" -print0 |
            xargs -0 -r file --mime-type |
            awk -F: '$2 ~ /text\// {print $1}'
        )
    else
        yellow_message "Skipped:" "Extensionless files (no 'file' utility available)."
    fi

    all_files=( "${ext_files[@]}" "${noext_files[@]}" )

    for file in "${all_files[@]}"; do
        if grep -Fq -- "$text" "$file"; then
            green_message "FILE:" "$file"
            grep -Fn -- "$text" "$file" | sed "s/^/    /"
            printf "\n"
        fi
    done
}

append_text() {
    if [ "$#" -ne 2 ]; then
        red_message "append_text:" "Expected 2 arguments, got $#."
        return 1
    fi

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
    if [ "$#" -ne 2 ]; then
        red_message "prepend_text:" "Expected 2 arguments, got $#."
        return 1
    fi

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
    if [ "$#" -ne 2 ]; then
        red_message "remove_text:" "Expected 2 arguments, got $#."
        return 1
    fi

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
    if [ "$#" -ne 1 ]; then
        red_message "trim_trailing_blanks:" "Expected 1 argument, got $#."
        return 1
    fi

    local filename="$1"

    if sudo_run sed -i ':a;/^[[:space:]]*$/{$d;N;ba}' "$filename"; then
        green_message "Success:" "Trimmed trailing blanks from '$filename'."
    else
        red_message "Error:" "Failed to trim trailing blanks from '$filename'."
        return 1
    fi
}

apply_utf16_substitutions() {
    if [ "$#" -lt 2 ]; then
        red_message "apply_utf16_substitutions:" "Expected at least 2 arguments, got $#."
        return 1
    fi

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
        "rpm-ostree")
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
        "rpm-ostree")
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
    if [ "$#" -eq 0 ]; then
        red_message "add_kernel_parameter:" "Expected at least 1 argument, got $#."
        return 1
    fi

    detect_system
    local updated=0

    for karg in "$@"; do
        if _kernel_parameter_exists "$karg"; then
            green_message "Already present:" "$karg"
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
        sudo bash -c "$update_bootloader"
    fi
}

_kernel_parameter_delete() {
    local karg="$1"
    case "$primary_pm" in
        "rpm-ostree")
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
    if [ "$#" -eq 0 ]; then
        red_message "remove_kernel_parameter:" "Expected at least 1 argument, got $#."
        return 1
    fi

    detect_system
    local updated=0
    for karg in "$@"; do
        if ! _kernel_parameter_exists "$karg"; then
            green_message "Already not present:" "$karg"
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
        sudo bash -c "$update_bootloader"
    fi
}
