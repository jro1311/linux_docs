#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2016,SC2154

set -euo pipefail

ld_bash_dir="$HOME/Documents/linux_docs/configs/system/bash/bash.d"

shopt -s nullglob globstar
for file in "$ld_bash_dir"/**/*.sh; do
    [ -e "$file" ] || continue
    . "$file"
done
shopt -u nullglob globstar

dir="$HOME/Documents/linux_docs"
file="$dir/readme.md"
tmp_old="$(mktemp)"
tmp_new="$(mktemp)"

if [ ! -d "$dir" ]; then
    red_message "Error:" "Missing '$dir'."
    exit 1
fi

cd "$dir"

sed -n '/^```/,/^```/p' "$file" \
    | sed \
        -e '/^```/d' \
        -e '/^[0-9]\+ directories, [0-9]\+ files$/d' \
    > "$tmp_old"

tree -a --dirsfirst -I '.git' \
    | sed '/^[0-9]\+ directories, [0-9]\+ files$/d' \
    > "$tmp_new"

if diff -u "$tmp_old" "$tmp_new"; then
    green_message "Already up to date:" "No changes detected."
    exit 0
fi

{
    echo '```'
    cat "$tmp_new"
    echo '```'
} > "$file"

green_message "Success:" "Updated readme.md."
