# shellcheck shell=bash
# shellcheck source=/dev/null

fast_source() {
    shopt -s globstar nullglob 2>/dev/null || return 1

    local base=$1
    local rc

    for rc in "$base"/**/*.sh; do
        . "$rc"
    done
}

safe_source() {
    local base=$1
    local rc

    for rc in "$base"/*.sh; do
        [ -e "$rc" ] || continue
        . "$rc"
    done

    for rc in "$base/helpers"/*.sh; do
        [ -e "$rc" ] || continue
        . "$rc"
    done

    for rc in "$base/install_packages"/*.sh; do
        [ -e "$rc" ] || continue
        . "$rc"
    done

    for rc in "$base/configure_packages"/*.sh; do
        [ -e "$rc" ] || continue
        . "$rc"
    done
}

source_all() {
    local base=$1

    if fast_source "$base"; then
        return 0
    fi

    safe_source "$base"
}
