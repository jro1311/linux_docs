# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

configure_btop() {
    local overwrite="${1:-0}"

    if [ "$overwrite" -eq 1 ] \
        || [ ! -f "$HOME/.config/btop/btop.conf" ]; then
        mkdir -p "$HOME/.config/btop"
        cp "$HOME/Documents/linux_docs/configs/applications/btop.conf" "$HOME/.config/btop/"
    fi
}

configure_htop() {
    local overwrite="${1:-0}"

    if [ "$overwrite" -eq 1 ] \
        || [ ! -f "$HOME/.config/htop/htoprc" ]; then
        mkdir -p "$HOME/.config/htop"
        cp "$HOME/Documents/linux_docs/configs/applications/htoprc" "$HOME/.config/htop/"
    fi
}
