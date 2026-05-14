# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

configure_fonts() {
    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/system/fontconfig/fonts.conf"
    local target="$HOME/.config/fontconfig/fonts.conf"

    copy_config "$overwrite" "$source" "$target"
}

configure_redshift() {
    command -v redshift >/dev/null 2>&1 || return 0

    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/applications/redshift.conf"
    local target="$HOME/.config/redshift.conf"
    local exec"redshift"
    local suffix=""

    copy_config "$overwrite" "$source" "$target"
    get_location "$overwrite"

    sed -i '/^lat=/d; /^lon=/d' "$target"

    {
        echo "lat=$latitude"
        echo "lon=$longitude"
    } >> "$target"

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
