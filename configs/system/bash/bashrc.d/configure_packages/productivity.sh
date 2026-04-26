# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

configure_micro() {
    local overwrite="${1:-0}"

    if [ "$overwrite" -eq 1 ] \
        || [ ! -f "$HOME/.config/micro/settings.json" ]; then
        cp "$HOME/Documents/linux_docs/configs/applications/micro/settings.json" "$HOME/.config/micro/"
    fi
}

configure_nano() {
    local overwrite="${1:-0}"

    if [ "$overwrite" -eq 1 ] \
        || [ ! -f "$HOME/.config/nano/nanorc" ] || [ ! -f /etc/nanorc ];then
        cp "$HOME/Documents/linux_docs/configs/applications/nanorc" "$HOME/.config/nano/"
        sudo cp "$HOME/Documents/linux_docs/configs/applications/nanorc" /etc/nanorc
    fi
}
