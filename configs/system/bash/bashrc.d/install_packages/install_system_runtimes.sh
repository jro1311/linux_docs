# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

install_btrfsmaintenance() {
    detect_system
    if ! mount | grep -Fq "type btrfs"; then
        yellow_message "Not detected:" "btrfs partition(s)"
        return 1
    fi

    if [ "$init_system" != "systemd" ]; then
        unsupported_init_system
        return 1
    fi

    case "$primary_pm" in
        "apt"|"dnf"|"zypper"|"rpm-ostree")
            install_packages "btrfsmaintenance"
            ;;
        "eopkg"|"xbps")
            yellow_message "No 'btrfsmaintenance' package available for $primary_pm."
            return 0
            ;;
        "pacman")
            enable_chaotic_aur
            case "$secondary_pm" in
                "paru"|"yay")
                    "$secondary_pm" -S --needed --noconfirm btrfsmaintenance
                    ;;
                *)
                    install_yay
                    yay -S --needed --noconfirm btrfsmaintenance
                    ;;
            esac
            ;;
        *)
            unsupported_package_manager
            return 1
            ;;
    esac

    # Configures systemd timers and paths
    sudo systemctl disable btrfs-defrag.timer
    sudo systemctl disable btrfs-trim.timer
    sudo systemctl enable btrfs-balance.timer
    sudo systemctl enable btrfs-scrub.timer
    sudo systemctl enable btrfsmaintenance-refresh.path

    green_message "Installed:" "btrfsmaintenance"
}

install_redshift() {
    detect_system
    declare -A redshift=(
        [apt]="redshift-gtk"
        [dnf]="redshift-gtk"
        [eopkg]="redshift-gtk"
        [pacman]="redshift"
        [xbps]="redshift-gtk"
        [zypper]="redshift-gtk"
        [rpm-ostree]="redshift-gtk"
    )

    install_packages "${redshift[$primary_pm]}"
    install_packages "jq"

    mkdir -pv "$HOME/.config/autostart"
    cp -v "$HOME/Documents/linux_docs/configs/applications/redshift/redshift.conf" "$HOME/.config/"
    cp -v "$HOME/Documents/linux_docs/configs/applications/redshift/redshift.desktop" "$HOME/.config/autostart/"

    # Define coordinates
    if [ -f "$HOME/Documents/location_info.conf" ]; then
        source "$HOME/Documents/location_info.conf"
        latitude="$lat"
        longitude="$long"
    else
        location=$(curl -sS http://ip-api.com/json)
        latitude=$(echo "$location" | jq -r '.lat')
        longitude=$(echo "$location" | jq -r '.lon')

        if [ "$latitude" = "null" ] || [ "$longitude" = "null" ]; then
            red_message "Error:" "Failed to get coordinates."
            return 1
        fi

        echo "lat=$latitude" | tee -a "$HOME/Documents/location_info.conf"
        echo "long=$longitude" | tee -a "$HOME/Documents/location_info.conf"
    fi

    echo "lat=$latitude" >> "$HOME/.config/redshift.conf"
    echo "lon=$longitude" >> "$HOME/.config/redshift.conf"

    if command -v redshift-gtk >/dev/null 2>&1; then
        echo "Exec=redshift-gtk" >> "$HOME/.config/autostart/redshift.desktop"

    elif command -v redshift >/dev/null 2>&1; then
        echo "Exec=redshift" >> "$HOME/.config/autostart/redshift.desktop"
    fi

    green_message "Installed:" "redshift"
}

install_tlp() {
    detect_system
    install_packages "tlp"

    if [ "$primary_pm" = "rpm-ostree" ]; then
        reboot_required "tlp"
        return 0
    fi

    if [ "$flatpak_installed" -eq 1 ]; then
        flatpak install flathub -y com.github.d4nj1.tlpui
    fi

    enable_service "tlp"

    green_message "Installed:" "tlp"
}

install_zram() {
    detect_system
    declare -A zram_generator=(
        [apt]="systemd-zram-generator"
        [dnf]="zram-generator"
        [eopkg]="zram-generator"
        [pacman]="zram-generator"
        [xbps]="zramen"
        [zypper]="zram-generator"
        [rpm-ostree]="zram-generator"
    )

    local algo=""
    local size="100"
    if [ "$battery_detected" -eq 1 ]; then
        algo="lz4"
    else
        algo="zstd"
    fi

    case "$init_system" in
        "systemd")
            install_packages "${zram_generator[$primary_pm]}"
            sudo cp -v "$HOME/Documents/linux_docs/configs/system/zram/zram-generator.conf" /etc/systemd/

            # Changes compression algorithm from zstd to lz4
            if [ "$battery_detected" -eq 1 ]; then
                sudo sed -i 's/zstd/lz4/g' /etc/systemd/zram-generator.conf
            fi

            # Reloads systemd manager configuration
            sudo systemctl daemon-reload
            ;;
        "dinit"|"openrc"|"runit"|"s6"|"sysvinit")
            if [ "$primary_pm" = "xbps" ]; then
                install_packages "${zram_generator[$primary_pm]}"

                if zramctl /dev/zram* >/dev/null 2>&1; then
                    sudo zramen toss
                fi

                # Creates zram swap device with same size as RAM
                sudo zramen make -a "$algo" -s "$size"

                # Adds command(s) to boot sequence
                if ! grep -Fq "zramen" /etc/rc.local; then
                    echo "zramen make -a $algo -s $size" | sudo tee -a /etc/rc.local >/dev/null 2>&1
                fi
            else
                # Loads zram module at boot
                sudo mkdir -pv /etc/modules.load.d
                echo zram | sudo tee /etc/modules-load.d/zram.conf >/dev/null 2>&1

                memory_bytes=$(free -b | grep Mem | awk '{printf $2}')

                # Creates udev rule
                sudo mkdir -pv /etc/udev/rules.d
                echo 'ACTION=="add", KERNEL=="zram0", ATTR{initstate}=="0", ATTR{comp_algorithm}="'"$algo"'", ATTR{disksize}="'"$memory_bytes"'"' | sudo tee /etc/udev/rules.d/99-zram.rules >/dev/null 2>&1

                # Adds fstab entry
                if ! grep -Fq "/dev/zram0" /etc/fstab; then
                    echo "/dev/zram0 none swap defaults,discard,pri=100,x-systemd.makefs 0 0" | sudo tee -a /etc/fstab >/dev/null 2>&1
                fi
            fi
            ;;
        *)
            unsupported_init_system
            return 1
            ;;
    esac

    if [ -f /etc/sysctl.d/99-swap.conf ]; then
        sudo rm -v /etc/sysctl.d/99-swap.conf
    fi

    sudo mkdir -pv /etc/sysctl.d
    sudo cp -v "$HOME/Documents/linux_docs/configs/system/zram/99-zram.conf" /etc/sysctl.d/

    # Reads and applies kernel parameter settings
    sudo sysctl -p /etc/sysctl.d/99-zram.conf

    # Replaces swap meter with zram in htop
    if [ -f "$HOME/.config/htop/htoprc" ]; then
        sed -i 's/Swap/Zram/g' "$HOME/.config/htop/htoprc"
    fi

    green_message "Installed:" "zram"
}

