#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

bashd_dir="$HOME/Documents/linux_docs/configs/system/bash/bashrc.d"

for file in "$bashd_dir"/*.sh; do
    [ -e "$file" ] || continue
    . "$file"
done

for dir in helpers configure_packages install_packages; do
    for file in "$bashd_dir/$dir"/*.sh; do
        [ -e "$file" ] || continue
        . "$file"
    done
done

ensure_pkg "shfmt" || true

target_dir=""
result=""
format=""
format_cmd=""
in_width=""

target_dir=$(input_directory "Enter target directory (default: $HOME/Documents)" "$HOME/Documents")
green_message "Target:" "$target_dir"

result=$(select_indentation_format)
format="${result%%|*}"
format_cmd="${result#*|}"

if [ -z "$format" ]; then
    exit 0
fi

in_width=$(input_positive_integer "indentation width")

print_field "Format" "$format"
print_field "Indentation Width" "$in_width characters"

confirm_proceed

restore_metadata() {
    local file="$1"
    local mode="$2"
    local owner="$3"
    local group="$4"

    chmod "$mode" "$file"
    chown "$owner":"$group" "$file"
}

mv_tmp_file() {
    local file="$1"

    if ! mv "$file.tmp" "$file"; then
        red_message "Error:" "Failed to move '$file.tmp'."
        conversion_failed=1
    fi
}

conversion_failed=0
all_files=()
collect_text_files "$target_dir" all_files

for file in "${all_files[@]}"; do
    orig_mode=$(stat -c '%a' "$file")
    orig_owner=$(stat -c '%u' "$file")
    orig_group=$(stat -c '%g' "$file")

    case "$file" in
        *.sh)
            if command -v shfmt > /dev/null 2>&1; then
                if [ "$format_cmd" = "expand" ]; then
                    shfmt -i "$in_width" -ci -sr -ln bash -- "$file" > "$file.tmp"
                else
                    shfmt -i 0 -ci -sr -ln bash -- "$file" > "$file.tmp"
                fi

                restore_metadata "$file.tmp" "$orig_mode" "$orig_owner" "$orig_group"
                mv_tmp_file "$file"

                continue
            fi
            ;;
    esac

    if "$format_cmd" -t "$in_width" -- "$file" > "$file.tmp"; then
        restore_metadata "$file.tmp" "$orig_mode" "$orig_owner" "$orig_group"
        mv_tmp_file "$file"
    else
        red_message "Error:" "Failed to convert '$file'."
        conversion_failed=1
    fi
done

if [ "$conversion_failed" -eq 0 ]; then
    green_message "Success:" "'$target_dir'"
else
    red_message "Failure:" "'$target_dir'"
    exit 1
fi
