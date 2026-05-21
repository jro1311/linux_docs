# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

configure_btop() {
    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/applications/btop.conf"
    local target="$HOME/.config/btop/btop.conf"
    local speeds_defined=0

    if define_network_speeds; then
        print_network_speeds
        speeds_defined=1
    fi

    pkill -x -SIGINT btop 2>/dev/null || :
    copy_config "$overwrite" "$source" "$target"

    if [ "$speeds_defined" -eq 1 ]; then
        sed -i \
            -e "s/^net_download *= *.*/net_download = $download_speed_mb/" \
            -e "s/^net_upload *= *.*/net_upload = $upload_speed_mb/" \
            "$target"
    fi
}

configure_htop() {
    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/applications/htoprc"
    local target="$HOME/.config/htop/htoprc"

    detect_system

    pkill -x -SIGINT htop 2>/dev/null || :
    copy_config "$overwrite" "$source" "$target"

    if [ "$swapfile_exists" -eq 1 ] || [ "$swap_partition_exists" -eq 1 ]; then
        sed -i 's/\<Zram\>/Swap/' "$target"
    else
        sed -i 's/\<Swap\>/Zram/' "$target"
    fi
}
