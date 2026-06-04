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

ensure_sudo_default() {
    local option="$1"
    local file="$2"
    local path="/etc/sudoers.d/99-$file"

    sudo mkdir -p /etc/sudoers.d

    if ! sudo grep -Fq "$option" "$path" 2>/dev/null; then
        printf '%s\n' "$option" | \
            sudo EDITOR='tee' visudo -f "$path" >/dev/null
    fi
}

configure_sudo() {
    ensure_sudo_default "Defaults pwfeedback" "pwfeedback"
    ensure_sudo_default "Defaults timestamp_timeout=30" "timeout"
}

apply_btrfs_cow_policies() {
    detect_system

    local var_directory
    local home_directory
    local all_paths=()
    local restore_needed_paths=()

    if [ "$var_fs" = "btrfs" ]; then
        local -a var_cow_directories=(
            /var/lib/flatpak
        )

        local -a var_nocow_directories=(
            /var/lib/libvirt/images
            /var/lib/machines
            /var/log/journal
        )

        for var_directory in "${var_cow_directories[@]}"; do
            sudo mkdir -p "$var_directory" || return 1
            sudo chattr -C "$var_directory" || return 1
            all_paths+=("$var_directory")
        done

        for var_directory in "${var_nocow_directories[@]}"; do
            sudo mkdir -p "$var_directory" || return 1
            sudo chattr +C "$var_directory" || return 1
            all_paths+=("$var_directory")
        done
    fi

    if [ "$home_fs" = "btrfs" ]; then
        local -a home_cow_directories=(
            "$HOME/.local/share/flatpak"
        )

        local -a home_nocow_directories=(
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
            home_nocow_directories+=(
                "$HOME/snap/steam/common/.local/share/Steam/steamapps/downloading"
                "$HOME/snap/steam/common/.local/share/Steam/steamapps/shadercache"
                "$HOME/snap/steam/common/.local/share/Steam/steamapps/temp"
            )
        fi

        for home_directory in "${home_cow_directories[@]}"; do
            mkdir -p "$home_directory" || return 1
            chattr -C "$home_directory" || return 1
            all_paths+=("$home_directory")
        done

        for home_directory in "${home_nocow_directories[@]}"; do
            mkdir -p "$home_directory" || return 1
            chattr +C "$home_directory" || return 1
            all_paths+=("$home_directory")
        done
    fi

    # Restore SELinux labels only when necessary
    for path in "${all_paths[@]}"; do
        if ! matchpathcon "$path" >/dev/null 2>&1; then
            restore_needed_paths+=("$path")
        fi
    done

    if [ "${#restore_needed_paths[@]}" -gt 0 ]; then
        restorecon_paths "${restore_needed_paths[@]}" || return 1
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
    detect_system

    local svc
    local -a services=(
        NetworkManager-wait-online.service
        casper-md5check.service
        casper.service
    )

    case "$init_system" in
        systemd)
            for svc in "${services[@]}"; do
                disable_service "$svc"      2>/dev/null || :
                sudo systemctl mask "$svc"  2>/dev/null || :
            done
            ;;
    esac

    case "$bootloader" in
        grub)
            set_kv_option "compact" "GRUB_TIMEOUT" "5" "/etc/default/grub"
            set_kv_option "compact" "GRUB_RECORDFAIL_TIMEOUT" "-1" "/etc/default/grub"
            set_kv_option "compact" "GRUB_TIMEOUT_STYLE" "menu" "/etc/default/grub"
            set_kv_option "compact" "GRUB_FORCE_HIDDEN_MENU" "false" "/etc/default/grub"
            set_kv_option "compact" "GRUB_DISABLE_SUBMENU" "false" "/etc/default/grub"

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
    local add_services remove_services add_ports

    sudo firewall-cmd --permanent --new-zone="$zone" >/dev/null 2>&1 || :

    remove_services=(
        dhcp
        dhcpv6
        dns
        dns-over-quic
        dns-over-tls
        http
        http3
        slp
        ssh
    )

    add_services=(
        bittorrent-lsd
        dhcpv6-client
        ipp
        ipp-client
        mdns
        samba-client
        spotify-sync
        terraria
        transmission-client
    )

    add_ports=(
        161-162/tcp 9100/tcp
        161-162/udp 9100/udp
        51413/tcp
        51413/udp
    )

    sudo firewall-cmd --permanent --zone="$zone" \
        "${remove_services[@]/#/--remove-service=}" \
        >/dev/null 2>&1 || :

    sudo firewall-cmd --permanent --zone="$zone" \
        "${add_services[@]/#/--add-service=}" \
        >/dev/null 2>&1 || return 1

    sudo firewall-cmd --permanent --zone="$zone" \
        "${add_ports[@]/#/--add-port=}" \
        >/dev/null 2>&1 || return 1

    sudo firewall-cmd --reload >/dev/null 2>&1 || return 1
}

apply_pm_config() {
    local settings_applied=0
    detect_system

    case "$primary_pm" in
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
