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

    detect_system

    if [ "$ram_gib" -le 4 ]; then
        ram_free_threshold=4
        swap_free_threshold=4

    elif [ "$ram_gib" -le 8 ]; then
        ram_free_threshold=6
        swap_free_threshold=6

    elif [ "$ram_gib" -le 16 ]; then
        ram_free_threshold=8
        swap_free_threshold=8

    else
        ram_free_threshold=10
        swap_free_threshold=10
    fi

    printf 'EARLYOOM_ARGS="-m %s -s %s -r 600"\n' \
        "$ram_free_threshold" "$swap_free_threshold" \
        | sudo tee /etc/default/earlyoom >/dev/null
}

configure_swap() {
    local overwrite="${1:-0}"
    detect_system

    if [ "$swapfile_exists" -eq 1 ]; then
        if [ "$overwrite" -eq 1 ] || [ ! -f /etc/sysctl.d/99-swap.conf ]; then
            sudo mkdir -p /etc/sysctl.d
            sudo cp "$HOME/Documents/linux_docs/configs/system/99-swap.conf" /etc/sysctl.d/
            sudo sysctl -p /etc/sysctl.d/99-swap.conf
        fi

        enable_zswap
    fi
}

_configure_zram_generator() {
    local algo="$1"

    sudo cp "$HOME/Documents/linux_docs/configs/system/zram/zram-generator.conf" /etc/systemd/

    if [ "$algo" = "lz4" ]; then
        sudo sed -i 's/zstd/lz4/g' /etc/systemd/zram-generator.conf
    fi

    sudo systemctl daemon-reload
}

_configure_zramen() {
    local algo="$1"
    local size="$2"

    if compgen -G "/dev/zram*" >/dev/null 2>&1; then
        sudo zramen toss
    fi

    sudo zramen make -a "$algo" -s "$size"

    if [ ! -f /etc/rc.local ]; then
        printf '%s\n' \
            '#!/usr/bin/env bash' \
            'exit 0' \
            | sudo tee /etc/rc.local >/dev/null
    fi

    sudo chmod +x /etc/rc.local

    if ! grep -Fq "exit 0" /etc/rc.local; then
        echo "exit 0" | sudo tee -a /etc/rc.local
    fi

    if ! grep -Fq "zramen" /etc/rc.local; then
        sudo sed -i "/^exit 0$/i zramen make -a $algo -s $size" /etc/rc.local
    fi
}

_configure_zram_manual() {
    local algo="$1"

    if [ ! -f /etc/rc.local ]; then
        printf '%s\n' \
            '#!/usr/bin/env bash' \
            'exit 0' \
            | sudo tee /etc/rc.local >/dev/null
    fi

    sudo chmod +x /etc/rc.local

    if ! grep -Fq "modprobe zram" /etc/rc.local; then
        sudo sed -i '/^exit 0$/i modprobe zram' /etc/rc.local
        sudo sed -i "/^exit 0$/i zramctl /dev/zram0 --algorithm $algo --size $ram_bytes" /etc/rc.local
        sudo sed -i '/^exit 0$/i mkswap -U clear /dev/zram0' /etc/rc.local
        sudo sed -i '/^exit 0$/i swapon --discard --priority 100 /dev/zram0' /etc/rc.local
    fi

    if ! compgen -G /dev/zram*; then
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
        if [ "$overwrite" -eq 1 ] || [ ! -f /etc/systemd/zram-generator.conf ]; then
            _configure_zram_generator "$algo"
        fi

    elif command -v zramen >/dev/null 2>&1; then
        if [ "$overwrite" -eq 1 ] || ! grep -Fq "zramen" /etc/rc.local 2>/dev/null; then
            _configure_zramen "$algo" "$size"
        fi

    else
        _configure_zram_manual "$algo"
    fi

    if [ "$overwrite" -eq 1 ] \
        || [ ! -f /etc/sysctl.d/99-zram.conf ]; then
        sudo mkdir -p /etc/sysctl.d
        sudo cp "$HOME/Documents/linux_docs/configs/system/zram/99-zram.conf" /etc/sysctl.d/
        sudo sysctl -p /etc/sysctl.d/99-zram.conf
    fi

    if [ ! -f /etc/modprobe.d/disable-auto-zram.conf ]; then
        echo "blacklist zram" | sudo tee /etc/modprobe.d/disable-auto-zram.conf
        rebuild_initramfs
    fi

    sudo rm -f /etc/sysctl.d/99-swap.conf

    if [ -f "$HOME/.config/htop/htoprc" ]; then
        sed -i 's/\<Swap\>/Zram/' "$HOME/.config/htop/htoprc"
    fi
}
