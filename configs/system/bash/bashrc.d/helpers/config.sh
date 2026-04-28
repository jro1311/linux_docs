# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

update_bootloader() {
    detect_system
    [ -z "$bootloader" ] && return 0

    announce_bootloader_update "$bootloader"

    # shellcheck disable=SC2086
    if [ -n "$update_bootloader_args" ]; then
        sudo "$update_bootloader_cmd" $update_bootloader_args
    else
        sudo "$update_bootloader_cmd"
    fi
}

enable_cow() {
    assert_arity "$#" "ge" 1 "<path>" || return 1
    sudo_run chattr -C "$@"
}

enable_cow_recursive() {
    assert_arity "$#" "ge" 1 "<path>"  || return 1
    sudo_run chattr -R -C "$@"
}

disable_cow() {
    assert_arity "$#" "ge" 1 "<path>"  || return 1
    sudo_run chattr +C "$@"
}

disable_cow_recursive() {
    assert_arity "$#" "ge" 1 "<path>"  || return 1
    sudo_run chattr -R +C "$@"
}

apply_btrfs_cow_policies() {
    detect_system

    if [ "$root_fs" = "btrfs" ]; then
        root_cow_dirs=(
            /var/lib/flatpak
        )

        root_nocow_dirs=(
            /var/lib/libvirt/images
            /var/lib/machines
            /var/log/journal
        )

        for root_cow_dir in "${root_cow_dirs[@]}"; do
            sudo_run_passthrough mkdir -p "${root_cow_dir[@]}" || return 1
            sudo_run chattr -C "${root_cow_dir[@]}" || return 1
        done

        for root_nocow_dir in "${root_nocow_dirs[@]}"; do
            sudo_run_passthrough mkdir -p "${root_nocow_dir[@]}" || return 1
            sudo_run chattr +C "${root_nocow_dir[@]}" || return 1
        done
    fi

    if [ "$home_fs" = "btrfs" ]; then
        home_cow_dirs=(
            "$HOME/.local/share/flatpak"
        )

        home_nocow_dirs=(
            "$HOME/.local/share/gnome-boxes/images"
            "$HOME/.var/app/org.gnome.Boxes/data/gnome-boxes/images"
        )

        for home_cow_dir in "${home_cow_dirs[@]}"; do
            sudo_run_passthrough mkdir -p "${home_cow_dir[@]}" || return 1
            sudo_run chattr -C "${home_cow_dir[@]}" || return 1
        done

        for home_nocow_dir in "${home_nocow_dirs[@]}"; do
            sudo_run_passthrough mkdir -p "${home_nocow_dir[@]}" || return 1
            sudo_run chattr +C "${home_nocow_dir[@]}" || return 1
        done
    fi
}

ensure_wheel_membership() {
    getent group wheel >/dev/null 2>&1 || return 0

    if id -nG "$USER" | grep -qw wheel; then
        green_message "$USER:" "already has wheel membership"
        return 0
    fi

    sudo usermod -aG wheel "$USER" || return 1
    green_message "$USER:" "added to 'wheel' group"
}

add_firewall_exceptions() {
    command -v firewall-cmd >/dev/null 2>&1 || return 0

    detect_system
    local zone="home"

    if [ -n "$network_interface" ]; then
        sudo firewall-cmd --add-interface="$network_interface" --zone="$zone" || return 1
    fi

    sudo firewall-cmd --set-default-zone="$zone" || return 1

    local services=(
        bittorrent-lsd
        dhcp
        dhcpv6
        dhcpv6-client
        dns
        dns-over-quic
        dns-over-tls
        http
        http3
        mdns
        samba-client
        slp
        spotify-sync
        ssh
        terraria
        transmission-client
    )

    for svc in "${services[@]}"; do
        sudo firewall-cmd --zone="$zone" --add-service="$svc" --permanent || return 1
    done

    local ports=(
        161-162/tcp 9100/tcp
        161-162/udp 9100/udp
    )

    for port in "${ports[@]}"; do
        sudo firewall-cmd --zone="$zone" --add-port="$port" --permanent || return 1
    done

    sudo firewall-cmd --reload || return 1

    green_message "Firewall exceptions applied:" "$network_interface"
}

apply_pm_config() {
    local settings_applied=0
    detect_system

    case "$primary_pm" in
        dnf)
            if confirm "Default $primary_pm operations to 'yes'? [y/N]"; then
                sudo sed -i '/defaultyes/d' /etc/dnf/dnf.conf || return 1
                echo "defaultyes = yes" | sudo tee -a /etc/dnf/dnf.conf || return 1
                settings_applied=1
            fi
            ;;
        pacman)
            # Removes cached versions of packages except the latest and one prior version
            sudo paccache -rk1 || return 1

            if [ "$init_system" = "systemd" ]; then
                sudo systemctl enable --now paccache.timer || return 1
            fi

            settings_applied=1
            ;;
    esac

    if [ "$settings_applied" -eq 1 ]; then
        green_message "Package manager configuration applied:" "$primary_pm"
    fi
}

enable_permanent_mac_address() {
    if command -v nmcli >/dev/null 2>&1; then
        if [ ! -f /etc/NetworkManager/conf.d/10-permanent-mac-address.conf ]; then
            sudo mkdir -p /etc/NetworkManager/conf.d || return 1
            sudo cp "$HOME/Documents/linux_docs/configs/system/network_manager/10-permanent-mac-address.conf" /etc/NetworkManager/conf.d/ || return 1
            restart_service "NetworkManager" || return 1
        fi
    fi

    return 0
}

enable_xorg_vrr() {
    case "$XDG_SESSION_TYPE" in
        x11)
            detect_system
            if [ "$amd_gpu_detected" eq 1 ]; then
                sudo cp "$HOME/Documents/linux_docs/configs/system/xorg/10-amdgpu.conf" /etc/X11/xorg.conf.d/ || return 1
            fi
            ;;
        wayland)
            return 0
            ;;
        *)
            unsupported_session_type
            return 1
            ;;
    esac
}

enable_zswap() {
    detect_system

    local algo=""
    if [ "$battery_detected" -eq 1 ]; then
        algo="lz4"
    else
        algo="zstd"
    fi

    echo 1 | sudo tee /sys/module/zswap/parameters/enabled >/dev/null 2>&1 || return 1
    echo Y | sudo tee /sys/module/zswap/parameters/shrinker_enabled >/dev/null 2>&1 || return 1
    echo 50 | sudo tee /sys/module/zswap/parameters/max_pool_percent >/dev/null 2>&1 || return 1
    echo "$algo" | sudo tee /sys/module/zswap/parameters/compressor >/dev/null 2>&1 || return 1
    if [ -f /sys/module/zswap/parameters/zpool ]; then
        echo zsmalloc | sudo tee /sys/module/zswap/parameters/zpool >/dev/null 2>&1 || return 1
    fi
    echo 90 | sudo tee /sys/module/zswap/parameters/accept_threshold_percent >/dev/null 2>&1 || return 1

    remove_kernel_parameter "zswap.enabled=0" || return 1

    add_kernel_parameter \
        "zswap.enabled=1" \
        "zswap.shrinker_enabled=1" \
        "zswap.max_pool_percent=50" \
        "zswap.compressor=$algo" \
        "zswap.zpool=zsmalloc" \
        "zswap.accept_threshold_percent=90" || return 1

    if [ -f /etc/sysctl.d/99-zram.conf ]; then
        sudo rm /etc/sysctl.d/99-zram.conf || return 1
    fi

    if [ ! -f /etc/sysctl.d/99-swap.conf ]; then
        sudo cp "$HOME/Documents/linux_docs/configs/system/99-swap.conf" /etc/sysctl.d/ || return 1
    fi

    sudo sed -i 's/^vm\.swappiness[[:space:]]*=[[:space:]]*.*/vm.swappiness = 100/' /etc/sysctl.d/99-swap.conf || return 1
    sudo sed -i 's/^vm\.page-cluster[[:space:]]*=[[:space:]]*.*/vm.page-cluster = 1/' /etc/sysctl.d/99-swap.conf || return 1
    sudo sysctl -p /etc/sysctl.d/99-swap.conf || return 1
}

disable_zswap() {
    detect_system

    local algo=""
    if [ "$battery_detected" -eq 1 ]; then
        algo="lz4"
    else
        algo="zstd"
    fi

    echo 0 | sudo tee /sys/module/zswap/parameters/enabled >/dev/null 2>&1 || return 1

    remove_kernel_parameter \
        "zswap.enabled=1" \
        "zswap.shrinker_enabled=1" \
        "zswap.max_pool_percent=50" \
        "zswap.compressor=$algo" \
        "zswap.zpool=zsmalloc" \
        "zswap.accept_threshold_percent=90" || return 1

    add_kernel_parameter "zswap.enabled=0" || return 1

    if [ ! -f /etc/sysctl.d/99-swap.conf ]; then
        sudo cp "$HOME/Documents/linux_docs/configs/system/99-swap.conf" /etc/sysctl.d/ || return 1
    fi

    sudo sed -i 's/^vm\.swappiness[[:space:]]*=[[:space:]]*.*/vm.swappiness = 30/' /etc/sysctl.d/99-swap.conf || return 1
    sudo sed -i 's/^vm\.page-cluster[[:space:]]*=[[:space:]]*.*/vm.page-cluster = 3/' /etc/sysctl.d/99-swap.conf || return 1
    sudo sysctl -p /etc/sysctl.d/99-swap.conf || return 1
}

install_aur_helper() {
    local helper="$1"

    detect_system

    if [ "$primary_pm" != "pacman" ]; then
        unsupported_package_manager
        return 1
    fi

    sudo pacman -S --needed --noconfirm base-devel git || return 1
    git clone "https://aur.archlinux.org/${helper}.git" || return 1

    cd "$helper" || return 1
    makepkg -si --noconfirm || return 1
    cd .. || return 1

    rm -rf "$helper" || return 1

    secondary_pm="$helper"
}

install_paru() { install_aur_helper "paru"; }

install_yay()  { install_aur_helper "yay"; }
