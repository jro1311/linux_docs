#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2016,SC2034,SC2154

mv_safe() {
    sudo_run_verbose mv -iv -- "$@"
}

cp_safe() {
    sudo_run_verbose cp -irv -- "$@"
}

rm_safe() {
    sudo_run_verbose rm -Irv --preserve-root -- "$@"
}

find_files() {
    assert_arity "$#" "ge" 1 "<file> <base>" || return 1

    local file="$1"
    local base="${2:-.}"

    find "$base" -type f -name "*${file}*" 2>/dev/null
}

find_dirs() {
    assert_arity "$#" "ge" 1 "<dir> <base>" || return 1

    local dir="$1"
    local base="${2:-.}"

    find "$base" -type d -name "*${dir}*" 2>/dev/null
}

enable_cow() {
    assert_arity "$#" "ge" 1 "<path>" || return 1
    sudo_run chattr -C "$@"
}

disable_cow() {
    assert_arity "$#" "ge" 1 "<path>" || return 1
    sudo_run chattr +C "$@"
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

count_lines() {
    assert_arity "$#" "eq" 1 "<directory>" || return 1

    local dir="$1"

    find "$dir" -type f -print0 |
        xargs -0 wc -l |
        awk '{s+=$1} END{print s}'
}

count_lines_breakdown() {
    assert_arity "$#" "eq" 1 "<directory>" || return 1

    local dir="$1"

    find "$dir" -type f -print0 |
        xargs -0 -n1 sh -c '
            for f do
                printf "%7d  %s\n" "$(wc -l < "$f")" "$f"
            done
        ' sh |
        sort -nr
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

create_autostart_entry() {
    assert_arity "$#" "range" 1 2 "<name> <exec>" || return 1

    local name="$1"
    local exec="${2:-}"

    mkdir -p "$HOME/.config/autostart"

    if [ ! -f "$HOME/.config/autostart/$name.desktop" ] ;then
        cat > "$HOME/.config/autostart/$name.desktop" <<-EOF
[Desktop Entry]
Type=Application
Name=$name
Exec=$exec
EOF
    else
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

        dir=$(strip_trailing_slash "$dir")

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

prepend_text() {
    assert_arity "$#" "eq" 2 "<text> <filename>" || return 1

    local text="$1"
    local file="$2"
    local tmp

    tmp=$(mktemp) || return 1

    if ! { printf '%s\n' "$text"; cat "$file"; } >"$tmp"; then
        red_message "Error:" "Failed to build temporary file for '$file'."
        rm -f "$tmp"
        return 1
    fi

    if sudo_run install \
            -m "$(stat -c %a "$file")" \
            --owner="$(stat -c %U "$file")" \
            --group="$(stat -c %G "$file")" \
            "$tmp" "$file"; then
        green_message "Success:" "'$text' prepended to '$file'."
    else
        red_message "Error:" "Failed to prepend text to '$file'."
        rm -f "$tmp"
        return 1
    fi

    rm -f "$tmp"
}

trim_trailing_blanks() {
    assert_arity "$#" "eq" 1 "<filename>" || return 1

    local file="$1"

    # shellcheck disable=SC2016
    if sudo_run sed -i ':a;/^[[:space:]]*$/{$d;N;ba}' "$file"; then
        green_message "Success:" "Trimmed trailing blanks from '$file'."
    else
        red_message "Error:" "Failed to trim trailing blanks from '$file'."
        return 1
    fi
}

clean_git() {
    local dir="${1:-$LD_ROOT}"
    git -C "$dir" gc --aggressive --prune=now
}

check_weather() {
    local script
    script="$(resolve_script check_weather.sh)" || return 1
    "$script" "$@"
}

chmod_scripts() {
    local script
    script="$(resolve_script chmod_scripts.sh)" || return 1
    [ ! -x "$script" ] && chmod +x "$script"
    "$script" "$@"
}

copy_pkg_configs() {
    local script
    script="$(resolve_script copy_pkg_configs.sh)" || return 1
    "$script" "$@"
}

create_swapfile() {
    local script
    script="$(resolve_script create_swapfile.sh)" || return 1
    "$script" "$@"
}

dos2unix_converter() {
    local script
    script="$(resolve_script dos2unix_converter.sh)" || return 1
    "$script" "$@"
}

export_smart_info() {
    local script
    script="$(resolve_script export_smart_info.sh)" || return 1
    "$script" "$@"
}

find_text() {
    local script
    script="$(resolve_script find_text.sh)" || return 1
    "$script" "$@"
}

generate_dnd_character() {
    local script
    script="$(resolve_script generate_dnd_character.sh)" || return 1
    "$script" "$@"
}

git_clone_repo() {
    local script
    script="$(resolve_script git_clone_repo.sh)" || return 1
    "$script" "$@"
}

git_push_repo() {
    local script
    script="$(resolve_script git_push_repo.sh)" || return 1
    "$script" "$@"
}

git_sync_repo() {
    local script
    script="$(resolve_script git_sync_repo.sh)" || return 1
    "$script" "$@"
}

remove_snap() {
    local script
    script="$(resolve_script remove_snap.sh)" || return 1
    "$script" "$@"
}

remove_swapfile() {
    local script
    script="$(resolve_script remove_swapfile.sh)" || return 1
    "$script" "$@"
}

replace_text() {
    local script
    script="$(resolve_script replace_text.sh)" || return 1
    "$script" "$@"
}

setup_btrfs_subvolumes() {
    local script
    script="$(resolve_script setup_btrfs_subvolumes.sh)" || return 1
    "$script" "$@"
}

setup_gaming() {
    local script
    script="$(resolve_script setup_gaming.sh)" || return 1
    "$script" "$@"
}

setup_system() {
    local script
    script="$(resolve_script setup_system.sh)" || return 1
    "$script" "$@"
}

shellcheck_all() {
    local script
    script="$(resolve_script shellcheck_all.sh)" || return 1
    "$script" "$@"
}

snake_case_converter() {
    local script
    script="$(resolve_script snake_case_converter.sh)" || return 1
    "$script" "$@"
}

sync_backup_drives() {
    local script
    script="$(resolve_script sync_backup_drives.sh)" || return 1
    "$script" "$@"
}

sync_bashd() {
    local script
    script="$(resolve_script sync_bashd.sh)" || return 1
    "$script" "$@"
}

sync_directory() {
    local script
    script="$(resolve_script sync_directory.sh)" || return 1
    "$script" "$@"
}

tab_space_converter() {
    local script
    script="$(resolve_script tab_space_converter.sh)" || return 1
    "$script" "$@"
}

tweak_games() {
    local script
    script="$(resolve_script tweak_games.sh)" || return 1
    "$script" "$@"
}

update_readme() {
    local script
    script="$(resolve_script update_readme.sh)" || return 1
    "$script" "$@"
}
