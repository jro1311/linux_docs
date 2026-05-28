# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

update_bootloader() {
    detect_system
    [ -z "$bootloader" ] && return 0

    announce_bootloader_update "$bootloader"

    # shellcheck disable=SC2086
    if [ -n "$update_bootloader_cmd" ]; then
        sudo "$update_bootloader_cmd" $update_bootloader_args
    fi
}

rebuild_initramfs() {
    detect_system

    if [ -z "$initramfs_backend" ]; then
        red_message "Error:" "Unsupported initramfs backend."
        return 1
    fi

    announce_initramfs_rebuild "$initramfs_backend"

    # shellcheck disable=SC2086
    if [ -n "$initramfs_args" ]; then
        sudo "$initramfs_cmd" $initramfs_args || return 1
    else
        sudo "$initramfs_cmd" || return 1
    fi

    return 0
}

ensure_wheel_membership() {
    getent group wheel >/dev/null 2>&1 || return 0

    if id -nG "$USER" | grep -qw wheel; then
        return 0
    fi

    sudo usermod -aG wheel "$USER" || return 1
    green_message "$USER:" "added to 'wheel' group"
}

configure_sudo() {
    sudo mkdir -p /etc/sudoers.d
    if ! sudo grep -Fq "timestamp_timeout=30" /etc/sudoers.d/timeout 2>/dev/null; then
        printf "Defaults timestamp_timeout=30\n" | \
            sudo EDITOR='tee' visudo -f /etc/sudoers.d/timeout
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

    if [ "$var_fs" = "btrfs" ]; then
        local -a var_cow_dirs=(
            /var/lib/flatpak
        )

        local -a var_nocow_dirs=(
            /var/lib/libvirt/images
            /var/lib/machines
            /var/log/journal
        )

        local var_cow_dir var_nocow_dir

        for var_cow_dir in "${var_cow_dirs[@]}"; do
            sudo mkdir -p "$var_cow_dir" || return 1
            sudo chattr -C "$var_cow_dir" || return 1
        done

        for var_nocow_dir in "${var_nocow_dirs[@]}"; do
            sudo mkdir -p "$var_nocow_dir" || return 1
            sudo chattr +C "$var_nocow_dir" || return 1
        done
    fi

    if [ "$home_fs" = "btrfs" ]; then
        local -a home_cow_dirs=(
            "$HOME/.local/share/flatpak"
        )

        local -a home_nocow_dirs=(
            "$HOME/Downloads"
            "$HOME/.local/share/libvirt/images"
            "$HOME/.local/share/gnome-boxes/images"
            "$HOME/.var/app/org.gnome.Boxes/data/gnome-boxes/images"
            "$HOME/.local/share/Steam/steamapps/downloading"
            "$HOME/.local/share/Steam/steamapps/shadercache"
            "$HOME/.local/share/Steam/steamapps/temp"
            "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/downloading"
            "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/shadercache"
            "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/temp"
        )

        if [ "$snap_installed" -eq 1 ]; then
            home_nocow_dirs+=(
                "$HOME/snap/steam/common/.local/share/Steam/steamapps/downloading"
                "$HOME/snap/steam/common/.local/share/Steam/steamapps/shadercache"
                "$HOME/snap/steam/common/.local/share/Steam/steamapps/temp"
            )
        fi

        local home_cow_dir home_nocow_dir

        for home_cow_dir in "${home_cow_dirs[@]}"; do
            mkdir -p "$home_cow_dir" || return 1
            chattr -C "$home_cow_dir" || return 1
        done

        for home_nocow_dir in "${home_nocow_dirs[@]}"; do
            mkdir -p "$home_nocow_dir" || return 1
            chattr +C "$home_nocow_dir" || return 1
        done
    fi
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

    rm -rf "$helper"

    secondary_pm="$helper"
}

install_paru() { install_aur_helper "paru"; }

install_yay()  { install_aur_helper "yay"; }

optimize_boot() {
    local svc="NetworkManager-wait-online.service"

    detect_system

    case "$init_system" in
        systemd)
            disable_service "$svc" || :
            sudo systemctl mask "$svc" || :
            ;;
    esac

    case "$bootloader" in
        grub)
            set_grub_option "GRUB_TIMEOUT" "5"
            set_grub_option "GRUB_RECORDFAIL_TIMEOUT" "-1"
            set_grub_option "GRUB_TIMEOUT_STYLE" "menu"
            set_grub_option "GRUB_FORCE_HIDDEN_MENU" "false"
            set_grub_option "GRUB_DISABLE_SUBMENU" "false"

            update_bootloader
            ;;
    esac

    add_kernel_parameter "8250.nr_uarts=0"
}

enable_permanent_mac_address() {
    if command -v nmcli >/dev/null 2>&1; then
        if [ ! -f /etc/NetworkManager/conf.d/10-permanent-mac-address.conf ]; then
            sudo mkdir -p /etc/NetworkManager/conf.d || return 1
            sudo cp "$HOME/Documents/linux_docs/configs/system/network_manager/10-permanent-mac-address.conf" /etc/NetworkManager/conf.d/ || return 1
            nmcli general reload || return 1
        fi
    fi
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
}

apply_pm_config() {
    local settings_applied=0
    detect_system

    case "$primary_pm" in
        dnf)
            if confirm "Default $primary_pm operations to 'yes'? [y/N]"; then
                sudo sed -i '/defaultyes/d' /etc/dnf/dnf.conf || return 1
                echo "defaultyes = yes" | sudo tee -a /etc/dnf/dnf.conf >/dev/null || return 1
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
