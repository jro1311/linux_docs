# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

configure_fonts() {
    local overwrite="${1:-0}"

    if [ "$overwrite" -eq 1 ] \
        || [ ! -f "$HOME/.config/fontconfig/fonts.conf" ]; then
        cp -v "$HOME/Documents/linux_docs/configs/system/fontconfig/fonts.conf" "$HOME/.config/fontconfig/"
    fi
}

configure_redshift() {
    local overwrite="${1:-0}"

    if [ "$overwrite" -eq 1 ] \
        ||[ ! -f "$HOME/.config/redshift.conf" ]; then
        cp -v "$HOME/Documents/linux_docs/configs/applications/redshift.conf" "$HOME/.config/"

        get_location

        sed -i '/^lat=/ s/=.*$/=/' "$HOME/.config/redshift.conf"
        sed -i '/^lon=/ s/=.*$/=/' "$HOME/.config/redshift.conf"
        echo "lat=$latitude" >> "$HOME/.config/redshift.conf"
        echo "lon=$longitude" >> "$HOME/.config/redshift.conf"
    fi

    if [ ! -f "$HOME/.config/autostart/redshift.desktop" ]; then
        create_autostart_entry "Redshift" "redshift"

        if command -v redshift-gtk >/dev/null 2>&1; then
            sed -i 's/^Exec=redshift/Exec=redshift-gtk/' "$HOME/.config/autostart/redshift.desktop"
        fi
    fi
}
