# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

configure_fonts() {
    local overwrite="${1:-0}"

    if [ "$overwrite" -eq 1 ] \
        || [ ! -f "$HOME/.config/fontconfig/fonts.conf" ]; then
        mkdir -p "$HOME/.config/fontconfig"
        cp "$HOME/Documents/linux_docs/configs/system/fontconfig/fonts.conf" "$HOME/.config/fontconfig/"
    fi
}

configure_redshift() {
    local overwrite="${1:-0}"
    local exec suffix
    exec="redshift"
    suffix=""

    if [ "$overwrite" -eq 1 ] \
        ||[ ! -f "$HOME/.config/redshift.conf" ]; then
        mkdir -p "$HOME/.config"
        cp "$HOME/Documents/linux_docs/configs/applications/redshift.conf" "$HOME/.config/"

        get_location

        sed -i '/^lat=/ s/=.*$/=/' "$HOME/.config/redshift.conf"
        sed -i '/^lon=/ s/=.*$/=/' "$HOME/.config/redshift.conf"
        echo "lat=$latitude" >> "$HOME/.config/redshift.conf"
        echo "lon=$longitude" >> "$HOME/.config/redshift.conf"
    fi

    rm -f "$HOME"/.config/autostart/redshift*.desktop

    if command -v redshift-gtk >/dev/null 2>&1; then
        exec="redshift-gtk"
        suffix="-gtk"
    elif command -v redshift-qt >/dev/null 2>&1; then
        exec="redshift-qt"
        suffix="-qt"
    fi

    create_autostart_entry "redshift${suffix}" "$exec"
}
