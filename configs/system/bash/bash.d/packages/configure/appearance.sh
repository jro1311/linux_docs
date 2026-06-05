# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

configure_fonts() {
    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/system/fontconfig/fonts.conf"
    local target="$HOME/.config/fontconfig/fonts.conf"

    copy_config "$overwrite" "$source" "$target" "fontconfig"
}

configure_redshift() {
    if ! command -v redshift >/dev/null 2>&1; then
        skipped_configs+=("redshift")
        return 0
    fi

    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/applications/redshift.conf"
    local target="$HOME/.config/redshift.conf"
    local exec suffix variant

    copy_config "$overwrite" "$source" "$target"

    if [ "$overwrite" -eq 1 ] || [ ! -f "$target" ]; then
        get_location "$overwrite"

        sed -i '/^lat=/d; /^lon=/d' "$target"

        {
            echo "lat=$latitude"
            echo "lon=$longitude"
        } >> "$target"
    fi

    if command -v redshift-gtk >/dev/null 2>&1; then
        exec="redshift-gtk"
        suffix="-gtk"
    elif command -v redshift-qt >/dev/null 2>&1; then
        exec="redshift-qt"
        suffix="-qt"
    else
        exec="redshift"
        suffix=""
    fi

    for variant in "" "-gtk" "-qt"; do
        [ "$variant" = "$suffix" ] && continue
        rm -f "$HOME/.config/autostart/redshift${variant}.desktop"
    done

    create_autostart_entry "redshift${suffix}" "$exec"
}
