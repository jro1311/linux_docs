#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

ld_bash_dir="$HOME/Documents/linux_docs/configs/system/bash/bash.d"

for file in "$ld_bash_dir"/*.sh; do
    [ -e "$file" ] || continue
    . "$file"
done

for dir in helpers configure_packages install_packages; do
    for file in "$ld_bash_dir/$dir"/*.sh; do
        [ -e "$file" ] || continue
        . "$file"
    done
done

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

diff -u "$tmp_old" "$tmp_new"

{
    echo '```'
    cat "$tmp_new"
    echo '```'
} > "$file"

green_message "Success:" "Updated readme.md."
