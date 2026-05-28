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
    "$LD_SCR/check_weather.sh" "$@"
}

chmod_scripts() {
    [ ! -x "$LD_SCR/chmod_scripts.sh" ] && chmod +x "$LD_SCR/chmod_scripts.sh"
    "$LD_SCR/chmod_scripts.sh" "$@"
}

create_swapfile() {
    "$LD_SCR/create_swapfile.sh" "$@"
}

dos2unix_converter() {
    "$LD_SCR/dos2unix_converter.sh" "$@"
}

export_smart_info() {
    "$LD_SCR/export_smart_info.sh" "$@"
}

find_text() {
    "$LD_SCR/find_text.sh" "$@"
}

generate_dnd_character() {
    "$LD_SCR/generate_dnd_character.sh" "$@"
}

git_clone_repo() {
    "$LD_SCR/git_clone_repo.sh" "$@"
}

git_push_repo() {
    "$LD_SCR/git_push_repo.sh" "$@"
}

git_sync_repo() {
    "$LD_SCR/git_sync_repo.sh" "$@"
}

remove_snap() {
    "$LD_SCR/remove_snap.sh" "$@"
}

remove_swapfile() {
    "$LD_SCR/remove_swapfile.sh" "$@"
}

replace_text() {
    "$LD_SCR/replace_text.sh" "$@"
}

setup_gaming() {
    "$LD_SCR/setup_gaming.sh" "$@"
}

setup_system() {
    "$LD_SCR/setup_system.sh" "$@"
}

shellcheck_all() {
    "$LD_SCR/shellcheck_all.sh" "$@"
}

snake_case_converter() {
    "$LD_SCR/snake_case_converter.sh" "$@"
}

sync_backup_drives() {
    "$LD_SCR/sync_backup_drives.sh" "$@"
}

sync_bashd() {
    "$LD_SCR/sync_bashd.sh" "$@"
}

sync_directory() {
    "$LD_SCR/sync_directory.sh" "$@"
}

copy_pkg_configs() {
    "$LD_SCR/copy_pkg_configs.sh" "$@"
}

tab_space_converter() {
    "$LD_SCR/tab_space_converter.sh" "$@"
}

tweak_games() {
    "$LD_SCR/tweak_games.sh" "$@"
}

update_readme() {
    "$LD_SCR/update_readme.sh" "$@"
}
