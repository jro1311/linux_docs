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

configure_swap() {
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
    local algo="$1"
    local overwrite="$2"

    if [ "$overwrite" -eq 1 ] \
        || [ ! -f /etc/systemd/zram-generator.conf ]; then
        sudo cp "$HOME/Documents/linux_docs/configs/system/zram-generator.conf" /etc/systemd/

        if [ "$algo" = "lz4" ]; then
            sudo sed -i 's/^compression-algorithm =.*/compression-algorithm = lz4/' /etc/systemd/zram-generator.conf
        fi

        sudo systemctl daemon-reload
    fi
}

_configure_zramen() {
    local algo="$1"
    local size="$2"
    local overwrite="$3"

    if compgen -G "/dev/zram*" >/dev/null 2>&1; then
        sudo zramen toss
    fi

    sudo zramen make -a "$algo" -s "$size"

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
        sudo sed -i "/^exit 0$/i zramen make -a $algo -s $size" /etc/rc.local
    fi

    if [ "$overwrite" -eq 1 ] || \
        ! grep -Fq "zramen" /etc/rc.local; then
        sudo sed -i "/^exit 0$/i zramen make -a $algo -s $size" /etc/rc.local
    fi

    echo "exit 0" | sudo tee -a /etc/rc.local >/dev/null
}

_configure_zram_manual() {
    local algo="$1"
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
        sudo sed -i '/^exit 0$/i modprobe zram' /etc/rc.local
        sudo sed -i "/^exit 0$/i zramctl /dev/zram0 --algorithm $algo --size $ram_bytes" /etc/rc.local
        sudo sed -i '/^exit 0$/i mkswap -U clear /dev/zram0' /etc/rc.local
        sudo sed -i '/^exit 0$/i swapon --discard --priority 100 /dev/zram0' /etc/rc.local
    fi

    if [ "$overwrite" -eq 1 ] || \
        ! compgen -G /dev/zram* >/dev/null 2>&1; then
        sudo modprobe zram
        sudo zramctl /dev/zram0 --algorithm "$algo" --size "$ram_bytes"
        sudo mkswap -U clear /dev/zram0
        sudo swapon --discard --priority 100 /dev/zram0
    fi
}

configure_zram() {
    local overwrite="${1:-0}"

    local algo=""
    local size=100

    detect_system

    if [ "$battery_detected" -eq 1 ]; then
        algo="lz4"
    else
        algo="zstd"
    fi

    if [ -x /usr/lib/systemd/system-generators/zram-generator ] \
        || [ -x /usr/lib/systemd/system-generators/systemd-zram-generator ]; then
        _configure_zram_generator "$algo" "$overwrite"

    elif command -v zramen >/dev/null 2>&1; then
        if [ "$overwrite" -eq 1 ] || ! grep -Fq "zramen" /etc/rc.local 2>/dev/null; then
            _configure_zramen "$algo" "$size" "$overwrite"
        fi

    else
        _configure_zram_manual "$algo" "$overwrite"
    fi

    if [ "$overwrite" -eq 1 ] \
        || [ ! -f /etc/sysctl.d/99-zram.conf ]; then
        sudo mkdir -p /etc/sysctl.d
        sudo cp "$HOME/Documents/linux_docs/configs/system/sysctl/99-zram.conf" /etc/sysctl.d/
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
