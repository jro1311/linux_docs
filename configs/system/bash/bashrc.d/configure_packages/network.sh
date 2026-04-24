# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

configure_qbittorrent() {
    if [ ! -f "$HOME/.config/autostart/qbittorrent.desktop" ]; then
        ask_for_confirmation "Add qBittorrent to autostart?" \
            && create_autostart_entry "qBittorrent" "qbittorrent"
    fi
}

configure_transmission() {
    if [ ! -f "$HOME/.config/autostart/transmission.desktop" ]; then
        if ask_for_confirmation "Add Transmission to autostart?"; then
            create_autostart_entry "Transmission"

            if command -v transmission-gtk >/dev/null 2>&1; then
                sed -i 's/Exec=/Exec=transmission-gtk --minimized/' "$HOME/.config/autostart/transmission.desktop"

            elif command -v transmission-qt >/dev/null 2>&1; then
                sed -i 's/Exec=/Exec=transmission-qt --minimized/' "$HOME/.config/autostart/transmission.desktop"

            elif flatpak list --columns=app | grep -Fq "com.transmissionbt.Transmission"; then
                sed -i 's/Exec=/Exec=flatpak run com.transmissionbt.Transmission --minimized/' "$HOME/.config/autostart/transmission.desktop"

            elif snap list "transmission" >/dev/null 2>&1; then
                sed -i 's/Exec=/Exec=snap run transmission --minimized/' "$HOME/.config/autostart/transmission.desktop"
            fi
        fi
    fi
}
