# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

configure_mpv() {
    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/applications/mpv"
    local target
    local -a targets=(
        "$HOME/.config"
        "$HOME/.var/app/io.mpv.Mpv/config"
    )

    detect_system

    for target in "${targets[@]}"; do
        if [ "$overwrite" -eq 1 ] || [ ! -d "${target}/mpv" ]; then
            copy_config_dir "$overwrite" "$source" "$target/"

            if [ "$battery_detected" -eq 1 ]; then
                sed -i 's/profile=.*/profile=fast/' "${target}/mpv/mpv.conf"
            fi
        fi
    done
}
