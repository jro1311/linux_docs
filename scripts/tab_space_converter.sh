#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# shellcheck disable=SC2044
# Sources all .sh files in bashrc.d
for rc in $(find "$HOME/Documents/linux_docs/configs/system/bash/bashrc.d" -type f -name '*.sh' 2>/dev/null); do
    . "$rc"
done

ensure_pkg "shfmt" || true

target_dir=""

target_dir=$(input_directory "Enter target directory (default: $HOME/Documents)" "$HOME/Documents")
green_message "Target:" "$target_dir"

result=""
format=""
format_cmd=""
in_width=""

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

# Collects extensionless files that are confirmed text via MIME detection
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

conversion_failed=0

all_files=( "${ext_files[@]}" "${noext_files[@]}" )

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

                chmod "$orig_mode" "$file.tmp"
                chown "$orig_owner":"$orig_group" "$file.tmp"

                if mv "$file.tmp" "$file"; then
                    green_message "Converted:" "'$file'"
                else
                    red_message "Error:" "Failed to convert '$file'."
                    conversion_failed=1
                fi

                continue
            fi
            ;;
    esac

    if "$format_cmd" -t "$in_width" -- "$file" > "$file.tmp"; then
        chmod "$orig_mode" "$file.tmp"
        chown "$orig_owner":"$orig_group" "$file.tmp"

        if mv "$file.tmp" "$file"; then
            green_message "Converted:" "'$file'"
        else
            red_message "Error:" "Failed to convert '$file'."
            conversion_failed=1
        fi
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
