# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_configure_brave_native() {
    local overwrite="${1:-0}"
    local launch_args="$2"
    local brave_app brave_native

    brave_app="$HOME/.local/share/applications/brave-browser.desktop"
    brave_native="/usr/share/applications/brave-browser.desktop"

    if [ "$overwrite" -eq 1 ] || [ ! -f "$brave_app" ]; then
        rm -f "$brave_app"

        cat "$brave_native" > "$brave_app"
        sed -i "0,/^Exec=/s|^Exec=.*|Exec=/usr/bin/brave-browser-stable $launch_args %U|" "$brave_app"
    fi
}

_configure_brave_flatpak() {
    local overwrite="${1:-0}"
    local launch_args="$2"
    local brave_app brave_flatpak_sys brave_flatpak_user

    brave_app="$HOME/.local/share/applications/com.brave.Browser.desktop"
    brave_flatpak_sys="/var/lib/flatpak/exports/share/applications/com.brave.Browser.desktop"
    brave_flatpak_user="$HOME/.local/share/flatpak/exports/share/applications/com.brave.Browser.desktop"

    if [ "$overwrite" -eq 1 ] || [ ! -f "$brave_app" ]; then
        rm -f "$brave_app"

        if [ -f "$brave_flatpak_sys" ]; then
            cat "$brave_flatpak_sys" > "$brave_app"
        elif [ -f "$brave_flatpak_user" ]; then
            cat "$brave_flatpak_user" > "$brave_app"
        fi

        sed -i "0,/^Exec=/s|^Exec=.*|Exec=flatpak run com.brave.Browser --ozone-platform-hint=auto $launch_args|" "$brave_app"
    fi
}

configure_brave() {
    local overwrite="${1:-0}"
    local launch_args=""

    mkdir -p "$HOME/.local/share/applications"
    launch_args="--disk-cache-dir=/dev/shm/brave-cache --media-cache-dir=/dev/shm/brave-cache --disk-cache-size=134217728"

    if command -v brave-browser >/dev/null 2>&1; then
        _configure_brave_native "$overwrite" "$launch_args"
    elif flatpak list --app --columns=app 2>/dev/null | grep -Fq "com.brave.Browser"; then
        _configure_brave_flatpak "$overwrite" "$launch_args"
    fi
}

configure_micro() {
    local overwrite="${1:-0}"

    if [ "$overwrite" -eq 1 ] \
        || [ ! -f "$HOME/.config/micro/settings.json" ]; then
        mkdir -p "$HOME/.config/micro"
        cp "$HOME/Documents/linux_docs/configs/applications/micro/settings.json" "$HOME/.config/micro/"
    fi
}

configure_nano() {
    local overwrite="${1:-0}"

    if [ "$overwrite" -eq 1 ] \
        || [ ! -f "$HOME/.config/nano/nanorc" ] || [ ! -f /etc/nanorc ];then
        mkdir -p "$HOME/.config/nano"
        cp "$HOME/Documents/linux_docs/configs/applications/nanorc" "$HOME/.config/nano/"
        sudo cp "$HOME/Documents/linux_docs/configs/applications/nanorc" /etc/nanorc
    fi
}
