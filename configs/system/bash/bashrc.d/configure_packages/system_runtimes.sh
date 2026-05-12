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
        "btrfs-defrag.timer" \
        "btrfs-trim.timer"

    enable_service \
        "btrfs-balance.timer" \
        "btrfs-scrub.timer" \
        "btrfsmaintenance-refresh.path"
}

configure_earlyoom() {
    local ram_free_threshold swap_free_threshold

    ram_free_threshold=5
    swap_free_threshold=5

    printf 'EARLYOOM_ARGS="-m %s -s %s -r 600"\n' \
        "$ram_free_threshold" "$swap_free_threshold" \
        | sudo tee /etc/default/earlyoom >/dev/null
}

configure_zswap() {
    local overwrite="${1:-0}"
    detect_system

    if [ "$swapfile_exists" -eq 1 ] || [ "$swap_partition_exists" -eq 1 ]; then
        if [ "$overwrite" -eq 1 ] || [ ! -f /etc/sysctl.d/99-zswap.conf ]; then
            sudo mkdir -p /etc/sysctl.d
            sudo cp "$HOME/Documents/linux_docs/configs/system/sysctl/99-zswap.conf" /etc/sysctl.d/
            sudo sysctl -p /etc/sysctl.d/99-zswap.conf
        fi

        sudo rm -f /etc/sysctl.d/99-zram.conf
        enable_zswap
    fi
}

_configure_zram_generator() {
    local overwrite="$1"

    if [ "$overwrite" -eq 1 ] \
        || [ ! -f /etc/systemd/zram-generator.conf ]; then
        sudo cp "$HOME/Documents/linux_docs/configs/system/zram-generator.conf" /etc/systemd/

        if [ "$comp_algo" = "lz4" ]; then
            sudo sed -i 's/^compression-algorithm =.*/compression-algorithm = lz4/' /etc/systemd/zram-generator.conf
        fi

        sudo systemctl daemon-reload
    fi
}

_configure_zramen() {
    local zram_percent="$1"
    local overwrite="$2"

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
    local target_size="$1"
    local overwrite="$2"

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
            sudo swapoff /dev/zram0 2>/dev/null || true
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
    local zram_percent target_size

    detect_system
    define_compression_algorithm

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

    if [ -x /usr/lib/systemd/system-generators/zram-generator ] \
        || [ -x /usr/lib/systemd/system-generators/systemd-zram-generator ]; then
        _configure_zram_generator "$overwrite"

    elif command -v zramen >/dev/null 2>&1; then
        if [ "$overwrite" -eq 1 ] || ! grep -Fq "zramen" /etc/rc.local 2>/dev/null; then
            _configure_zramen "$zram_percent" "$overwrite"
        fi

    else
        _configure_zram_manual "$target_size" "$overwrite"
    fi

    if [ "$overwrite" -eq 1 ] \
        || [ ! -f /etc/sysctl.d/99-zram.conf ]; then
        sudo mkdir -p /etc/sysctl.d
        sudo cp "$HOME/Documents/linux_docs/configs/system/sysctl/99-zram.conf" /etc/sysctl.d/

        if [ "$battery_detected" -eq 1 ]; then
            sudo sed -i \
                -e 's/^vm.swappiness *= *[0-9]\+/vm.swappiness = 60/' \
                -e 's/^vm.dirty_background_ratio *= *[0-9]\+/vm.dirty_background_ratio = 5/' \
                -e 's/^vm.dirty_ratio *= *[0-9]\+/vm.dirty_ratio = 10/' \
                /etc/sysctl.d/99-zram.conf
        fi

        sudo sysctl -p /etc/sysctl.d/99-zram.conf
    fi

    if [ ! -f /etc/modprobe.d/disable-auto-zram.conf ]; then
        echo "blacklist zram" | sudo tee /etc/modprobe.d/disable-auto-zram.conf >/dev/null
        rebuild_initramfs
    fi

    sudo rm -f /etc/sysctl.d/99-zswap.conf

    if [ -f "$HOME/.config/htop/htoprc" ]; then
        sed -i 's/\<Swap\>/Zram/' "$HOME/.config/htop/htoprc"
    fi
}
