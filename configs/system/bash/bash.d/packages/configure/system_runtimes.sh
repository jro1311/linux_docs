# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

configure_tlp() {
    enable_service "tlp"
}

configure_btrfsmaintenance() {
    detect_system

    if [ "$btrfs_detected" -eq 0 ]; then
        red_message "Error:" "btrfs not detected."
        return 1
    fi

    if [ "$init_system" != "systemd" ]; then
        unsupported_init_system
        return 1
    fi

    disable_service \
        "btrfs-defrag.timer"

    enable_service \
        "btrfs-trim.timer" \
        "btrfs-balance.timer" \
        "btrfs-scrub.timer" \
        "btrfsmaintenance-refresh.path"
}

configure_journald() {
    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/system/journald.conf"
    local target="/etc/systemd/journald.conf"

    detect_system

    if [ "$init_system" != "systemd" ]; then
        skipped_configs+=("journald")
        return 0
    fi

    if [ "$overwrite" -eq 1 ] || [ ! -f "$target" ]; then
        copy_config "$overwrite" "$source" "$target"
        restart_service "systemd-journald"
    fi

    success_configs+=("journald")
}

configure_earlyoom() {
    local ram_free_threshold swap_free_threshold

    ram_free_threshold=5
    swap_free_threshold=5

    printf 'EARLYOOM_ARGS="-m %s -s %s -r 600"\n' \
        "$ram_free_threshold" "$swap_free_threshold" \
        | sudo tee /etc/default/earlyoom >/dev/null
}

_enable_zswap() {
    echo 1 | sudo tee /sys/module/zswap/parameters/enabled >/dev/null || return 1
    echo Y | sudo tee /sys/module/zswap/parameters/shrinker_enabled >/dev/null || return 1
    echo 50 | sudo tee /sys/module/zswap/parameters/max_pool_percent >/dev/null || return 1
    echo "$comp_algo" | sudo tee /sys/module/zswap/parameters/compressor >/dev/null || return 1

    if [ -f /sys/module/zswap/parameters/zpool ]; then
        echo zsmalloc | sudo tee /sys/module/zswap/parameters/zpool >/dev/null || return 1
    fi

    echo 90 | sudo tee /sys/module/zswap/parameters/accept_threshold_percent >/dev/null || return 1

    remove_kernel_parameter "zswap.enabled=0" || return 1

    add_kernel_parameter \
        "zswap.enabled=1" \
        "zswap.shrinker_enabled=1" \
        "zswap.max_pool_percent=50" \
        "zswap.compressor=$comp_algo" \
        "zswap.zpool=zsmalloc" \
        "zswap.accept_threshold_percent=90" || return 1
}

_disable_zswap() {
    echo 0 | sudo tee /sys/module/zswap/parameters/enabled >/dev/null || return 1

    remove_kernel_parameter \
        "zswap.enabled=1" \
        "zswap.shrinker_enabled=1" \
        "zswap.max_pool_percent=50" \
        "zswap.compressor=zstd" \
        "zswap.compressor=lz4" \
        "zswap.zpool=zsmalloc" \
        "zswap.accept_threshold_percent=90" || return 1

    add_kernel_parameter "zswap.enabled=0" || return 1
}

configure_zswap() {
    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/system/sysctl/99-zswap.conf"
    local target="/etc/sysctl.d/99-zswap.conf"

    detect_system
    define_compression_algorithm
    print_compression_algorithm

    if [ "$swapfile_exists" -eq 1 ] || [ "$swap_partition_exists" -eq 1 ]; then
        remove_zram

        copy_config "$overwrite" "$source" "$target"
        sudo sysctl -p "$target"
        _enable_zswap

        success_configs+=("zswap")
    else
        _disable_zswap
        sudo rm -f /etc/sysctl.d/99-zswap.conf

        skipped_configs+=("zswap")
    fi
}

_configure_zram_generator() {
    local overwrite="$1"
    local source="$HOME/Documents/linux_docs/configs/system/zram-generator.conf"
    local target="/etc/systemd/zram-generator.conf"

    copy_config "$overwrite" "$source" "$target"

    if [ "$comp_algo" = "lz4" ]; then
        sudo sed -i 's/^compression-algorithm *=.*/compression-algorithm = lz4/' /etc/systemd/zram-generator.conf
    fi

    sudo systemctl daemon-reload
}

_configure_zramen() {
    local overwrite="$1"
    local zram_percent="$2"

    if compgen -G "/dev/zram*" >/dev/null 2>&1; then
        sudo zramen toss
    fi

    sudo zramen make -a "$comp_algo" -s "$zram_percent"

    if [ "$overwrite" -eq 1 ] \
        || [ ! -f /etc/rc.local ]; then
        printf '%s\n' '#!/usr/bin/env bash' | sudo tee /etc/rc.local >/dev/null
    fi

    sudo chmod +x /etc/rc.local
    sudo sed -i '/^exit 0$/d' /etc/rc.local

    if [ "$overwrite" -eq 1 ]; then
        sudo sed -i '/zramen make -a/d' /etc/rc.local
    fi

    if [ "$overwrite" -eq 1 ] \
        || ! grep -Fq "zramen make -a" /etc/rc.local; then
        sudo sed -i "/^exit 0$/i zramen make -a $comp_algo -s $zram_percent" /etc/rc.local
    fi

    if [ "$overwrite" -eq 1 ] || \
        ! grep -Fq "zramen" /etc/rc.local; then
        sudo sed -i "/^exit 0$/i zramen make -a $comp_algo -s $zram_percent" /etc/rc.local
    fi

    echo "exit 0" | sudo tee -a /etc/rc.local >/dev/null
}

_configure_zram_manual() {
    local overwrite="$1"
    local target_size="$2"

    if [ "$overwrite" -eq 1 ] || \
        [ ! -f /etc/rc.local ]; then
            printf '%s\n' \
                '#!/usr/bin/env bash' \
                'exit 0' \
                | sudo tee /etc/rc.local >/dev/null
    fi

    sudo chmod +x /etc/rc.local

    if [ "$overwrite" -eq 1 ] || \
        ! grep -Fq "modprobe zram" /etc/rc.local; then
        sudo sed -i \
            -e '/^exit 0$/i modprobe zram' \
            -e "/^exit 0$/i zramctl /dev/zram0 --algorithm $comp_algo --size $target_size" \
            -e '/^exit 0$/i mkswap -U clear /dev/zram0' \
            -e '/^exit 0$/i swapon --discard --priority 100 /dev/zram0' \
            /etc/rc.local
    fi

    if [ "$overwrite" -eq 1 ] \
        || ! grep -q "^/dev/zram0" /proc/swaps; then

        if [ -e /sys/block/zram0/disksize ] \
            && [ "$(cat /sys/block/zram0/disksize)" -ne 0 ]; then
            sudo swapoff /dev/zram0 2>/dev/null || :
            echo 1 | sudo tee /sys/block/zram0/reset >/dev/null
        fi

        sudo modprobe zram
        sudo zramctl /dev/zram0 --algorithm "$comp_algo" --size "$target_size"
        sudo mkswap -U clear /dev/zram0
        sudo swapon --discard --priority 100 /dev/zram0
    fi
}

configure_zram() {
    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/system/sysctl/99-zram.conf"
    local target="/etc/sysctl.d/99-zram.conf"
    local zram_percent target_size

    detect_system
    define_compression_algorithm
    print_compression_algorithm

    _disable_zswap
    sudo rm -f /etc/sysctl.d/99-zswap.conf

    if [ "$ram_gib" -le 32 ]; then
        zram_percent=100

    elif [ "$ram_gib" -le 64 ]; then
        zram_percent=50

    elif [ "$ram_gib" -le 128 ]; then
        zram_percent=25

    elif [ "$ram_gib" -le 256 ]; then
        zram_percent=12

    elif [ "$ram_gib" -le 512 ]; then
        zram_percent=6
    else
        zram_percent=3
    fi

    if [ "$ram_gib" -le 32 ]; then
        target_size="$ram_bytes"
    else
        target_size=34359738368
    fi

    copy_config "$overwrite" "$source" "$target"
    sudo sysctl -p "$target"

    if [ -x /usr/lib/systemd/system-generators/zram-generator ] \
        || [ -x /usr/lib/systemd/system-generators/systemd-zram-generator ]; then
        _configure_zram_generator "$overwrite"

    elif command -v zramen >/dev/null 2>&1; then
        if [ "$overwrite" -eq 1 ] || ! grep -Fq "zramen" /etc/rc.local 2>/dev/null; then
            _configure_zramen "$overwrite" "$zram_percent"
        fi

    else
        _configure_zram_manual "$overwrite" "$target_size"
    fi

    if [ ! -f /etc/modprobe.d/disable-auto-zram.conf ]; then
        echo "blacklist zram" | sudo tee /etc/modprobe.d/disable-auto-zram.conf >/dev/null
        rebuild_initramfs
    fi

    success_configs+=("zram")
}
