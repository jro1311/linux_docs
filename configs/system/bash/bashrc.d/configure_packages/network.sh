# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

configure_qbittorrent() {
    local file exec
    file="$HOME/.config/autostart/qbittorrent.desktop"

    if [ ! -f "$file" ]; then
        if confirm "Add qBittorrent to autostart? [y/N]"; then

            if command -v qbittorrent >/dev/null 2>&1; then
                exec="qbittorrent"

            elif flatpak list --columns=app | grep -Fq "org.qbittorrent.qBittorrent"; then
                exec="flatpak run org.qbittorrent.qBittorrent"

            elif snap list "qbittorrent" >/dev/null 2>&1; then
                exec="snap run qbittorrent"
            fi

            create_autostart_entry "qbittorrent" "$exec"
        fi
    fi
}

configure_transmission() {
    local file exec
    file="$HOME/.config/autostart/transmission.desktop"

    if [ ! -f "$file" ]; then
        if confirm "Add Transmission to autostart? [y/N]"; then

            if command -v transmission-gtk >/dev/null 2>&1; then
                exec="transmission-gtk --minimized"

            elif command -v transmission-qt >/dev/null 2>&1; then
                exec="transmission-qt --minimized"

            elif flatpak list --columns=app | grep -Fq "com.transmissionbt.Transmission"; then
                exec="flatpak run com.transmissionbt.Transmission --minimized"

            elif snap list "transmission" >/dev/null 2>&1; then
                exec="snap run transmission --minimized"
            fi

            create_autostart_entry "transmission" "$exec"
        fi
    fi
}
