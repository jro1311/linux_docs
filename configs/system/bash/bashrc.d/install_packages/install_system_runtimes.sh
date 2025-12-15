install_btrfsmaintenance() {
    if ! mount | grep -Fq "type btrfs"; then
        yellow_message "No btrfs partitions detected."
        return 1
    fi

    if [ "$init_system" != "systemd" ]; then
        unsupported_init_system
        return 1
    fi

    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y btrfsmaintenance
            ;;
        "dnf")
            sudo dnf install -y btrfsmaintenance
            ;;
        "eopkg")
            yellow_message "No package available for $primary_package_manager: 'btrfsmaintenance'"
            return 0
            ;;
        "pacman")
            enable_chaotic_aur
            case "$secondary_package_manager" in
                "paru"|"yay")
                    "$secondary_package_manager" -S --needed --noconfirm btrfsmaintenance
                    ;;
                *)
                    install_yay
                    yay -S --needed --noconfirm btrfsmaintenance
                    ;;
            esac
            ;;
        "zypper")
            sudo zypper in -y btrfsmaintenance
            ;;
        "rpm-ostree")
            inverse_check btrfsmaintenance \
                sudo rpm-ostree install btrfsmaintenance
                reboot_required
                return 0
            ;;
        *)
            unsupported_package_manager
            return 1
            ;;
    esac

    # Configures systemd timers and paths
    if systemctl list-unit-files | grep -Fq "btrfsmaintenance"; then
        sudo systemctl disable btrfs-defrag.timer
        sudo systemctl disable btrfs-trim.timer
        sudo systemctl enable btrfs-balance.timer
        sudo systemctl enable btrfs-scrub.timer
        sudo systemctl enable btrfsmaintenance-refresh.path
    fi

    green_message "btrfsmaintenance is now installed."
}

install_redshift() {
    declare -A redshift=(
        [apt]="redshift-gtk jq"
        [dnf]="redshift-gtk jq"
        [eopkg]="redshift-gtk jq"
        [pacman]="redshift jq"
        [xbps]="redshift-gtk jq"
        [zypper]="redshift-gtk jq"
        [rpm-ostree]="redshift-gtk jq"
    )

    install_packages() {
        local packages=("$@")
        case "$primary_package_manager" in
            "apt")
                sudo apt-get install -y "${packages[@]}"
                ;;
            "dnf")
                sudo dnf install -y "${packages[@]}"
                ;;
            "eopkg")
                sudo eopkg install -y "${packages[@]}"
                ;;
            "pacman")
                sudo pacman -S --needed --noconfirm "${packages[@]}"
                ;;
            "xbps")
                sudo xbps-install -Sy "${packages[@]}"
                ;;
            "zypper")
                sudo zypper in -y "${packages[@]}"
                ;;
            "rpm-ostree")
                inverse_check redshift-gtk || inverse_check jq \
                    sudo rpm-ostree install "${packages[@]}"
                ;;
            *)
                unsupported_package_manager
                return 1
                ;;
        esac
    }

    # Splits string into an array
    read -ra packages <<< "${redshift[$primary_package_manager]}"
    install_packages "${packages[@]}"

    mkdir -pv "$HOME/.config/autostart"
    cp -v "$HOME/Documents/linux_docs/configs/applications/redshift/redshift.conf" "$HOME/.config/"
    cp -v "$HOME/Documents/linux_docs/configs/applications/redshift/redshift.desktop" "$HOME/.config/autostart/"

    # Define coordinates
    location=$(curl -s "http://ipinfo.io/$(curl -s api.ipify.org)/json")
    latitude=$(echo "$location" | jq -r '.loc' | cut -d',' -f1)
    longitude=$(echo "$location" | jq -r '.loc' | cut -d',' -f2)

    echo "lat=$latitude" >> "$HOME/.config/redshift.conf"
    echo "lon=$longitude" >> "$HOME/.config/redshift.conf"

    if command -v redshift-gtk >/dev/null 2>&1; then
        echo "Exec=redshift-gtk" >> "$HOME/.config/autostart/redshift.desktop"

    elif command -v redshift >/dev/null 2>&1; then
        echo "Exec=redshift" >> "$HOME/.config/autostart/redshift.desktop"
    fi

    green_message "Redshift is now installed."
}

install_tlp() {
    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y tlp
            ;;
        "dnf")
            sudo dnf install -y tlp
            ;;
        "eopkg")
            sudo eopkg install -y tlp
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm tlp
            ;;
        "xbps")
            sudo xbps-install -Sy tlp
            ;;
        "zypper")
            sudo zypper in -y tlp
            ;;
        "rpm-ostree")
            inverse_check tlp \
                sudo rpm-ostree install tlp
                reboot_required
                return 0
            ;;
        *)
            unsupported_package_manager
            return 1
            ;;
    esac

    if [[ "$flatpak_installed" -eq 1 ]]; then
        flatpak install flathub -y com.github.d4nj1.tlpui
    fi

    case "$init_system" in
        "systemd")
            sudo systemctl enable --now tlp.service
            ;;
        "runit")
            sudo ln -s /etc/sv/tlp /var/service
            ;;
        *)
            unsupported_init_system
            return 1
            ;;
    esac

    green_message "TLP is now installed."
}

install_zram() {
    declare -A zram_package=(
        [apt]="systemd-zram-generator"
        [dnf]="zram-generator"
        [eopkg]="zram-generator"
        [pacman]="zram-generator"
        [xbps]="zramen"
        [zypper]="zram-generator"
        [rpm-ostree]="zram-generator"
    )

    install_packages "${zram_package[$primary_package_manager]}"

    sudo mkdir -pv /etc/sysctl.d
    sudo cp -v "$HOME/Documents/linux_docs/configs/system/zram/99-zram.conf" /etc/sysctl.d/

    case "$init_system" in
        "systemd")
            sudo cp -v "$HOME/Documents/linux_docs/configs/system/zram/zram-generator.conf" /etc/systemd/

            # Changes compression algorithm from zstd to lz4 on laptops
            if [ "$host_system" = "laptop" ]; then
                sudo sed -i 's/zstd/lz4/g' /etc/systemd/zram-generator.conf
            fi

            sudo systemctl daemon-reload

            if systemctl list-units | grep -Fq "systemd-zram-setup@zram0.service"; then
                sudo systemctl start systemd-zram-setup@zram0.service
            fi
            ;;
        "runit")
            if zramctl /dev/zram* >/dev/null 2>&1; then
                sudo zramen toss
            fi

            # Creates zram swap device with same size as RAM
            local algo="unknown"
            local size="100"
            if [ "$host_system" = "laptop" ]; then
                algo="lz4"
            else
                algo="zstd"
            fi

            sudo zramen make -a "$algo" -s "$size"

            # Adds command(s) to boot sequence
            if ! grep -Fq "zramen" /etc/rc.local; then
                echo "zramen make -a $algo -s $size" | sudo tee -a /etc/rc.local
            fi
            ;;
        *)
            unsupported_init_system
            return 1
            ;;
    esac

    # Reads and applies kernel parameter settings
    sudo sysctl -p /etc/sysctl.d/99-zram.conf

    green_message "zram is now installed."
}

