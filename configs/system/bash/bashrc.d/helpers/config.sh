# shellcheck shell=bash
# shellcheck source=/dev/null
# shellcheck disable=SC2034,SC2154

enable_cow() {
    if [ "$#" -eq 0 ]; then
        red_message "enable_cow:" "Expected at least 1 argument, got $#."
        return 1
    fi

    sudo_run chattr -C "$@"
}

enable_cow_recursive() {
    if [ "$#" -eq 0 ]; then
        red_message "enable_cow_recursive:" "Expected at least 1 argument, got $#."
        return 1
    fi

    sudo_run chattr -R -C "$@"
}

disable_cow() {
    if [ "$#" -eq 0 ]; then
        red_message "disable_cow:" "Expected at least 1 argument, got $#."
        return 1
    fi

    sudo_run chattr +C "$@"
}

disable_cow_recursive() {
    if [ "$#" -eq 0 ]; then
        red_message "disable_cow_recursive:" "Expected at least 1 argument, got $#."
        return 1
    fi

    sudo_run chattr -R +C "$@"
}

add_firewall_exceptions() {
    if command -v firewall-cmd >/dev/null 2>&1; then
        zone="home"

        if [ -n "$network_interface" ]; then
            sudo firewall-cmd --add-interface="$network_interface" --zone="$zone"
        fi

        sudo firewall-cmd --set-default-zone="$zone"

        local services=(
            bittorrent-lsd dhcp dhcpv6 dhcpv6-client dns dns-over-quic dns-over-tls
            http http3 mdns samba-client slp spotify-sync ssh terraria transmission-client
        )

        for svc in "${services[@]}"; do
            sudo firewall-cmd --zone="$zone" --add-service="$svc" --permanent
        done

        local ports=(
            161-162/tcp 9100/tcp
            161-162/udp 9100/udp
        )

        for port in "${ports[@]}"; do
            sudo firewall-cmd --zone="$zone" --add-port="$port" --permanent
        done

        sudo firewall-cmd --reload
    fi
}

enable_chaotic_aur() {
    detect_system
    if [ "$primary_pm" = "pacman" ]; then
        if ! grep -Fq "chaotic" /etc/pacman.conf; then
            sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
            sudo pacman-key --lsign-key 3056513887B78AEB
            sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
            sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
            sudo tee -a /etc/pacman.conf <<-'EOF'
            [chaotic-aur]
                Include = /etc/pacman.d/chaotic-mirrorlist

EOF
            green_message "Enabled:" "Chaotic AUR"
        fi
    else
        unsupported_package_manager
        return 1
    fi
}

enable_debian_contrib() {
    detect_system
    case "$os" in
        "debian")
            # Converts old sources.list format into modern debian.sources format
            sudo apt modernize-sources -y

            if ! grep -Fq "contrib" /etc/apt/sources.list.d/debian.sources; then
                sudo sed -i '/Components:/ s/$/ contrib/' /etc/apt/sources.list.d/debian.sources
                sudo apt-get update
            fi
            ;;
        "ubuntu")
            unsupported_operating_system
            return 1
            ;;
        *)
            case "$os_like" in
                "debian")
                    sudo apt modernize-sources -y

                    if ! grep -Fq "contrib" /etc/apt/sources.list.d/debian.sources; then
                        sudo sed -i '/Components:/ s/$/ contrib/' /etc/apt/sources.list.d/debian.sources
                        sudo apt-get update
                    fi
                    ;;
                *)
                    unsupported_operating_system
                    return 1
            esac
        ;;
    esac

    green_message "Enabled:" "Debian Contrib"
}

enable_debian_backports() {
    detect_system
    case "$os" in
        "debian")
            # Converts old sources.list format into modern debian.sources format
            sudo apt modernize-sources -y

            if ! [ -f /etc/apt/sources.list.d/debian_backports.sources ]; then
                sudo cp -v "$HOME/Documents/linux_docs/configs/system/debian_backports.sources" /etc/apt/sources.list.d/
                sudo sed -i "/Suites:/ s/version-backports/$(lsb_release -cs)-backports/" /etc/apt/sources.list.d/debian_backports.sources
                sudo apt-get update
            fi
            ;;
        "ubuntu")
            unsupported_operating_system
            return 1
            ;;
        *)
            case "$os_like" in
                "debian")
                    sudo apt modernize-sources -y

                    if [ ! -f /etc/apt/sources.list.d/debian_backports.sources ]; then
                        sudo cp -v "$HOME/Documents/linux_docs/configs/system/debian_backports.sources" /etc/apt/sources.list.d/
                        sudo sed -i "/Suites:/ s/version-backports/$(lsb_release -cs)-backports/" /etc/apt/sources.list.d/debian_backports.sources
                        sudo apt-get update
                    fi
                    ;;
                *)
                    unsupported_operating_system
                    return 1
            esac
        ;;
    esac

    green_message "Enabled:" "Debian Backports"
}

enable_permanent_mac_address() {
    if command -v nmcli >/dev/null 2>&1; then
        green_message "Detected:" "Network Manager"

        if [ ! -f /etc/NetworkManager/conf.d/10-permanent-mac-address.conf ]; then
            sudo mkdir -pv /etc/NetworkManager/conf.d
            sudo cp -v "$HOME/Documents/linux_docs/configs/system/network_manager/10-permanent-mac-address.conf" /etc/NetworkManager/conf.d/

            if command -v systemctl >/dev/null 2>&1; then
                sudo systemctl restart NetworkManager
            fi
        else
            green_message "Already enabled:" "Permanent MAC address"
            return 0
        fi
    else
        yellow_message "Not detected:" "Network Manager"
    fi

    green_message "Enabled:" "Permanent MAC address"
}

enable_service() {
    if [ "$#" -eq 0 ]; then
        red_message "enable_service" "Expected at least 1 argument, got $#."
        return 1
    fi

    detect_system
    local service="$1"

    case "$init_system" in
        "systemd")
            case "$service" in
                "tlp")
                    sudo systemctl enable --now tlp.service
                    ;;
                *)
                    sudo systemctl enable --now "$service"
                    ;;
            esac
            ;;
        "dinit")
            sudo ln -s "/etc/dinit.d/$service" /etc/dinit.d/boot.d/
            ;;
        "openrc")
            sudo rc-service "$service" start
            sudo rc-update add "$service"
            ;;
        "runit")
            sudo ln -s "/etc/sv/$service" /var/service
            ;;
        "s6")
            sudo ln -s "/etc/s6/sv/$service" /var/service/
            ;;
        "sysvinit")
            sudo update-rc.d "$service" enable
            sudo service "$service" start
            ;;
        *)
            unsupported_init_system
            return 1
            ;;
    esac
}

enable_xorg_vrr() {
    case "$XDG_SESSION_TYPE" in
        "x11")
            green_message "Session: X11"
            if echo "$gpu_info" | grep -Fiq "amd"; then
                green_message "Detected GPU: AMD"
                sudo cp -v "$HOME/Documents/linux_docs/configs/system/xorg/10-amdgpu.conf" /etc/X11/xorg.conf.d/
            else
                yellow_message "No AMD GPU detected."
                echo "Nothing to do."
                return 0
            fi
            ;;
        "wayland")
            green_message "Session: Wayland"
            echo "Nothing to do."
            return 0
            ;;
        *)
            red_message "Unknown session."
            return 1
            ;;
    esac

    green_message "Enabled:" "Variable Refresh Rate"
}

enable_zswap() {
    local compressor=""
    if [ "$battery_detected" -eq 1 ]; then
        compressor="lz4"
    else
        compressor="zstd"
    fi

    echo 1 | sudo tee /sys/module/zswap/parameters/enabled >/dev/null 2>&1
    echo Y | sudo tee /sys/module/zswap/parameters/shrinker_enabled >/dev/null 2>&1
    echo 50 | sudo tee /sys/module/zswap/parameters/max_pool_percent >/dev/null 2>&1
    echo "$compressor" | sudo tee /sys/module/zswap/parameters/compressor >/dev/null 2>&1
    if [ -f /sys/module/zswap/parameters/zpool ]; then
        echo zsmalloc | sudo tee /sys/module/zswap/parameters/zpool >/dev/null 2>&1
    fi
    echo 90 | sudo tee /sys/module/zswap/parameters/accept_threshold_percent >/dev/null 2>&1

    remove_kernel_parameter "zswap.enabled=0"
    add_kernel_parameter \
        "zswap.enabled=1" \
        "zswap.shrinker_enabled=1" \
        "zswap.max_pool_percent=50" \
        "zswap.compressor=$compressor" \
        "zswap.zpool=zsmalloc" \
        "zswap.accept_threshold_percent=90"

    if [ -f /etc/sysctl.d/99-zram.conf ]; then
        sudo rm -v /etc/sysctl.d/99-zram.conf
    fi

    sudo mkdir -pv /etc/sysctl.d
    sudo cp -v "$HOME/Documents/linux_docs/configs/system/99-swap.conf" /etc/sysctl.d/
    sudo sed -i 's/vm.swappiness \=\ 30/vm.swappiness \=\ 100/' /etc/sysctl.d/99-swap.conf
    echo "vm.page-cluster = 1" | sudo tee -a /etc/sysctl.d/99-swap.conf
    sudo sysctl -p /etc/sysctl.d/99-swap.conf

    green_message "Enabled:" "zswap"
}

disable_zswap() {
    local compressor=""
    if [ "$battery_detected" -eq 1 ]; then
        compressor="lz4"
    else
        compressor="zstd"
    fi

    echo 0 | sudo tee /sys/module/zswap/parameters/enabled >/dev/null 2>&1

    remove_kernel_parameter \
        "zswap.enabled=1" \
        "zswap.shrinker_enabled=1" \
        "zswap.max_pool_percent=50" \
        "zswap.compressor=$compressor" \
        "zswap.zpool=zsmalloc" \
        "zswap.accept_threshold_percent=90"
    add_kernel_parameter "zswap.enabled=0"

    if [ -f /etc/sysctl.d/99-swap.conf ]; then
        sudo sed -i 's/vm.swappiness \=\ 100/vm.swappiness \=\ 30/' /etc/sysctl.d/99-swap.conf
        sudo sed -i 's/vm.page-cluster \=\ 1//' /etc/sysctl.d/99-swap.conf
        sudo sysctl -p /etc/sysctl.d/99-swap.conf
    fi

    green_message "Disabled:" "zswap"
}

install_aur_helper() {
    detect_system
    local helper="$1"
    if [ "$primary_pm" != "pacman" ]; then
        unsupported_package_manager
        return 1
    fi

    sudo pacman -S --needed --noconfirm base-devel git
    git clone "https://aur.archlinux.org/${helper}.git"
    cd "$helper" || return 1
    makepkg -si --noconfirm
    cd ..
    rm -rf "$helper"

    secondary_pm="$helper"
    green_message "Installed:" "$helper"
}

install_paru() { install_aur_helper "paru"; }
install_yay()  { install_aur_helper "yay"; }
