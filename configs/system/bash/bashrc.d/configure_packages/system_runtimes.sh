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
    local memory_bytes="$2"

    if [ ! -f /etc/rc.local ]; then
        printf '%s\n' \
            '#!/usr/bin/env bash' \
            'exit 0' \
            | sudo tee /etc/rc.local >/dev/null
    fi

    sudo chmod +x /etc/rc.local

    if ! grep -Fq "modprobe zram" /etc/rc.local; then
        sudo sed -i '/^exit 0$/i modprobe zram' /etc/rc.local
        sudo sed -i "/^exit 0$/i zramctl /dev/zram0 --algorithm $algo --size $memory_bytes" /etc/rc.local
        sudo sed -i '/^exit 0$/i mkswap -U clear /dev/zram0' /etc/rc.local
        sudo sed -i '/^exit 0$/i swapon --discard --priority 100 /dev/zram0' /etc/rc.local
    fi

    if ! compgen -G /dev/zram*; then
        sudo modprobe zram
        sudo zramctl /dev/zram0 --algorithm "$algo" --size "$memory_bytes"
        sudo mkswap -U clear /dev/zram0
        sudo swapon --discard --priority 100 /dev/zram0
    fi
}

configure_zram() {
    local overwrite="${1:-0}"

    local algo=""
    local size=100
    local memory_bytes=""

    detect_system
    if [ "$battery_detected" -eq 1 ]; then
        algo="lz4"
    else
        algo="zstd"
    fi

    memory_bytes=$(free -b | grep Mem | awk '{printf $2}')

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
        _configure_zram_manual "$algo" "$memory_bytes"
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
