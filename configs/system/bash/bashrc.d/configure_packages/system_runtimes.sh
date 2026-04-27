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

    if ls /dev/zram* >/dev/null 2>&1; then
        sudo zramen toss
    fi

    sudo zramen make -a "$algo" -s "$size"

    if ! grep -Fq "zramen" /etc/rc.local; then
        echo "zramen make -a $algo -s $size" | sudo tee -a /etc/rc.local >/dev/null 2>&1
    fi
}

_configure_zram_manual() {
    local algo="$1"
    local memory_bytes="$2"

    sudo mkdir -p /etc/modules.load.d
    echo "zram" | sudo tee /etc/modules-load.d/zram.conf >/dev/null 2>&1

    sudo mkdir -p /etc/udev/rules.d
    echo 'ACTION=="add", KERNEL=="zram0", ATTR{initstate}=="0", ATTR{comp_algorithm}="'"$algo"'", ATTR{disksize}="'"$memory_bytes"'"' \
        | sudo tee /etc/udev/rules.d/99-zram.rules >/dev/null 2>&1

    if ! grep -Fq "/dev/zram0" /etc/fstab; then
        echo "/dev/zram0 none swap defaults,discard,pri=100,x-systemd.makefs 0 0" \
            | sudo tee -a /etc/fstab >/dev/null 2>&1
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

    if command -v zram-generator >/dev/null 2>&1 \
        || command -v systemd-zram-generator >/dev/null 2>&1; then
        if [ "$overwrite" -eq 1 ] || [ ! -f /etc/systemd/zram-generator.conf ]; then
            _configure_zram_generator "$algo"
        fi

    elif command -v zramen >/dev/null 2>&1; then
        if [ "$overwrite" -eq 1 ] || ! grep -Fq "zramen" /etc/rc.local; then
            _configure_zramen "$algo" "$size"
        fi

    else
        if [ "$overwrite" -eq 1 ] || [ ! -f /etc/udev/rules.d/99-zram.rules ]; then
            _configure_zram_manual "$algo" "$memory_bytes"
        fi
    fi

    sudo rm -f /etc/sysctl.d/99-swap.conf 2>/dev/null || true
    [ -f "$HOME/.config/htop/htoprc" ] && sed -i 's/Swap/Zram/g' "$HOME/.config/htop/htoprc"

    if [ "$overwrite" -eq 1 ] \
        || [ ! -f /etc/sysctl.d/99-zram.conf ]; then
        sudo cp "$HOME/Documents/linux_docs/configs/system/zram/99-zram.conf" /etc/sysctl.d/
        sudo sysctl -p /etc/sysctl.d/99-zram.conf
    fi
}
