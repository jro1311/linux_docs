# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

configure_btop() {
    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/applications/btop.conf"
    local target="$HOME/.config/btop/btop.conf"

    pkill -x btop 2>/dev/null || :
    copy_config "$overwrite" "$source" "$target"

    define_network_speeds
    print_network_speeds

    sed -i \
        -e "s/^net_download *= *.*/net_download = $download_speed_mib/" \
        -e "s/^net_upload *= *.*/net_upload = $upload_speed_mib/" \
        "$target"
}

configure_htop() {
    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/applications/htoprc"
    local target="$HOME/.config/htop/htoprc"

    detect_system

    pkill -x htop 2>/dev/null || :
    copy_config "$overwrite" "$source" "$target"

    if [ "$swapfile_exists" -eq 1 ] || [ "$swap_partition_exists" -eq 1 ]; then
        sed -i 's/\<Zram\>/Swap/' "$target"
    else
        sed -i 's/\<Swap\>/Zram/' "$target"
    fi
}
