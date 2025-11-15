install_qbittorrent() {
    mkdir -pv "$HOME/.config/autostart"
    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y qbittorrent
            ;;
        "dnf")
            sudo dnf install -y qbittorrent
            ;;
        "eopkg")
            sudo eopkg install -y qbittorrent
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm qbittorrent
            ;;
        "xbps")
            sudo xbps-install -Sy qbittorrent
            ;;
        "zypper")
            sudo zypper in -y qbittorrent
            ;;
        *)
            if [[ "$flatpak_installed" -eq 1 ]]; then
                flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
                flatpak install flathub -y org.qbittorrent.qBittorrent

                cp -v /var/lib/flatpak/exports/share/applications/org.qbittorrent.qBittorrent.desktop "$HOME/.config/autostart/"
                green_message "qBittorrent is now installed."
                return 0

            elif [[ "$snap_installed" -eq 1 ]]; then
                sudo snap install qbittorrent-arnatious

                cp -v /var/lib/snap/exports/share/applications/qbittorrent-arnatious.desktop "$HOME/.config/autostart/"
                green_message "qBittorrent is now installed."
                return 0
            else
                unsupported_package_manager
                return 1
            fi
            ;;
    esac

    cp -v /usr/share/applications/org.qbittorrent.qBittorrent.desktop "$HOME/.config/autostart/"

    green_message "qBittorrent is now installed."
}

install_transmission() {
    declare -A transmission_gtk=(
        [apt]="transmission-gtk"
        [dnf]="transmission-gtk"
        [eopkg]="transmission"
        [pacman]="transmission-gtk"
        [xbps]="transmission-gtk"
        [zypper]="transmission-gtk"
    )

    declare -A transmission_qt=(
        [apt]="transmission-qt"
        [dnf]="transmission-qt"
        [eopkg]="transmission"
        [pacman]="transmission-qt"
        [xbps]="transmission-qt"
        [zypper]="transmission-qt"
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
            *)
                if [ "$flatpak_installed" -eq 1 ]; then
                    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
                    flatpak install flathub -y com.transmissionbt.Transmission

                elif [ "$snap_installed" -eq 1 ]; then
                    sudo snap install transmission

                else
                    unsupported_package_manager
                    return 1
                fi
                ;;
        esac
    }

    case "$desktop" in
        "awesome"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"openbox"|"qtile"|"sway"|"xmonad"|*wm)
            install_packages "${transmission_qt[$primary_package_manager]}"
            ;;
        "budgie"|"cosmic"|"deepin"|"gnome"|"lxde"|"mate"|"pantheon"|"ubuntu"|"unity"|"x-cinnamon"|"xfce")
            install_packages "${transmission_gtk[$primary_package_manager]}"
            ;;
        "lxqt"|"kde"|"plasma")
            install_packages "${transmission_qt[$primary_package_manager]}"
            ;;
        *)
            install_packages "${transmission_gtk[$primary_package_manager]}"
            ;;
    esac

    if ask_for_confirmation "Add Transmission to autostart?"; then

        mkdir -pv "$HOME/.config/autostart"
        cp -v "$HOME/Documents/linux_docs/configs/packages/transmission.desktop" "$HOME/.config/autostart/"

        if command -v transmission-gtk >/dev/null 2>&1; then
            echo "Exec=transmission-gtk --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"

        elif command -v transmission-qt >/dev/null 2>&1; then
            echo "Exec=transmission-qt --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"

        elif [ "$flatpak_installed" -eq 1 ] && flatpak list | grep -Fq "com.transmissionbt.Transmission"; then
            echo "Exec=flatpak run com.transmissionbt.Transmission --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"

        elif [ "$snap_installed" -eq 1 ] && snap list | grep -Fiq "transmission"; then
            echo "Exec=snap run transmission --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"
        fi

    fi

    green_message "Transmission is now installed."
}
