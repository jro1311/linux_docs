install_qbittorrent() {
    detect_system
    mkdir -pv "$HOME/.config/autostart"

    package_installed=0
    if [ "$primary_package_manager" != "rpm-ostree" ]; then
        install_packages "qbittorrent" && package_installed=1
    fi

    if [ "$package_installed" -eq 0 ]; then
        if [ "$flatpak_installed" -eq 1 ]; then
            flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
            flatpak install flathub -y org.qbittorrent.qBittorrent

        elif [ "$snap_installed" -eq 1 ]; then
            sudo snap install qbittorrent-arnatious
        else
            unsupported_package_manager
            return 1
        fi
    fi

    if [ -f /usr/share/applications/org.qbittorrent.qBittorrent.desktop ]; then
        cp -v /usr/share/applications/org.qbittorrent.qBittorrent.desktop "$HOME/.config/autostart/"

    elif [ -f /var/lib/flatpak/exports/share/applications/org.qbittorrent.qBittorrent.desktop ]; then
        cp -v /var/lib/flatpak/exports/share/applications/org.qbittorrent.qBittorrent.desktop "$HOME/.config/autostart/"

    elif [ -f /var/lib/snap/exports/share/applications/qbittorrent-arnatious.desktop ]; then
        cp -v /var/lib/snap/exports/share/applications/qbittorrent-arnatious.desktop "$HOME/.config/autostart/"
    fi

    sed -i '/^# Translations/,${/^# Translations/d; d;}' "$HOME/.config/autostart/org.qbittorrent.qBittorrent.desktop"

    green_message "Installed:" "qBittorrent"
}

install_transmission() {
    detect_system
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

    window_managers=(
        "awesome"
        "enlightenment"
        "fluxbox"
        "hyprland"
        "i3"
        "openbox"
        "qtile"
        "sway"
        "xmonad"
    )

    qt_desktops=(
        "lxqt"
        "kde"
        "plasma"
    )

    gtk_desktops=(
        "budgie"
        "cosmic"
        "deepin"
        "gnome"
        "lxde"
        "mate"
        "pantheon"
        "ubuntu"
        "unity"
        "x-cinnamon"
        "xfce"
    )

    in_array() {
        local needle="$1"; shift
        local item
        for item in "$@"; do
            [[ "$item" == "$needle" ]] && return 0
        done
        return 1
    }

    is_window_manager() {
        local desktop="$1"
        in_array "$desktop" "${window_managers[@]}" && return 0
        [[ "$desktop" == *wm ]] && return 0
        return 1
    }

    package_installed=0
    if [ "$primary_package_manager" != "rpm-ostree" ]; then
        if in_array "$desktop" "${qt_desktops[@]}" || is_window_manager "$desktop"; then
            install_packages "${transmission_qt[$primary_package_manager]}" && package_installed=1

        elif in_array "$desktop" "${gtk_desktops[@]}"; then
            install_packages "${transmission_gtk[$primary_package_manager]}" && package_installed=1
        else
            install_packages "${transmission_gtk[$primary_package_manager]}" && package_installed=1
        fi
    fi

    if [ "$package_installed" -eq 0 ]; then
        if [ "$flatpak_installed" -eq 1 ]; then
            flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
            flatpak install flathub -y com.transmissionbt.Transmission

        elif [ "$snap_installed" -eq 1 ]; then
            sudo snap install transmission
        else
            unsupported_package_manager
            return 1
        fi
    fi

    if ask_for_confirmation "Add Transmission to autostart?"; then
        mkdir -pv "$HOME/.config/autostart"
        cp -v "$HOME/Documents/linux_docs/configs/applications/transmission.desktop" "$HOME/.config/autostart/"

        if command -v transmission-gtk >/dev/null 2>&1; then
            echo "Exec=transmission-gtk --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"

        elif command -v transmission-qt >/dev/null 2>&1; then
            echo "Exec=transmission-qt --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"

        elif [ "$flatpak_installed" -eq 1 ] && flatpak list --columns=app | grep -q "^com.transmissionbt.Transmission$"; then
            echo "Exec=flatpak run com.transmissionbt.Transmission --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"

        elif [ "$snap_installed" -eq 1 ] && snap list | grep -Fiq "transmission"; then
            echo "Exec=snap run transmission --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"
        fi
    fi

    green_message "Installed:" "transmission"
}
