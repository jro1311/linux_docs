# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

configure_btop() {
    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/applications/btop.conf"
    local target="$HOME/.config/btop/btop.conf"

    pkill -x btop 2>/dev/null || :
    copy_config "$overwrite" "$source" "$target"
}

configure_htop() {
    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/applications/htoprc"
    local target="$HOME/.config/htop/htoprc"

    pkill -x htop 2>/dev/null || :
    copy_config "$overwrite" "$source" "$target"
}
