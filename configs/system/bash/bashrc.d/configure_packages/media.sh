# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

configure_mpv() {
    local overwrite="${1:-0}"
    detect_system

    if [ "$overwrite" -eq 1 ] \
        || [ ! -d "$HOME/.config/mpv" ] || [ ! -d "$HOME/.var/app/io.mpv.Mpv/config/mpv" ]; then
        cp -r "$HOME/Documents/linux_docs/configs/applications/mpv" "$HOME/.config/"
        cp -r "$HOME/Documents/linux_docs/configs/applications/mpv" "$HOME/.var/app/io.mpv.Mpv/config/"

        # Switches mpv profile from high-quality to fast when on battery
        if [ "$battery_detected" -eq 1 ]; then
            sed -i 's/profile=high-quality/profile=fast/' "$HOME/.config/mpv/mpv.conf"
            sed -i 's/profile=high-quality/profile=fast/' "$HOME/.var/app/io.mpv.Mpv/config/mpv/mpv.conf"
        fi
    fi
}
