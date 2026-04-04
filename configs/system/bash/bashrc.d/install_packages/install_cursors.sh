install_cursor_bibata() {
    source_system_info
    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y bibata-cursor-theme
            ;;
        "dnf")
            case "$os" in
                "openmandriva")
                    yellow_message "Manual installation required."
                    yellow_message "Download:" "https://github.com/ful1e5/Bibata_Cursor"
                    return 0
                    ;;
                *)
                    sudo dnf config-manager --add-repo https://terra.fyralabs.com/terra.repo
                    sudo dnf install -y bibata-cursor-theme
                    ;;
            esac
            ;;
        "eopkg")
            sudo eopkg install -y bibata-cursors
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm bibata-cursor-theme
            ;;
        "zypper")
            sudo zypper in -y dmz-icon-theme-cursors
            ;;
        *)
            yellow_message "Manual installation required."
            yellow_message "Download:" "https://github.com/ful1e5/Bibata_Cursor"
            return 0
            ;;
    esac

    green_message "Installed:" "Bibata cursor"
}

install_cursor_dmz() {
    source_system_info
    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y dmz-cursor-theme
            ;;
        "eopkg")
            sudo eopkg install -y dmz-cursor-theme
            ;;
        "pacman")
            case "$secondary_package_manager" in
                "paru"|"yay")
                    "$secondary_package_manager" -S --needed --noconfirm xcursor-dmz
                    ;;
                *)
                    install_yay
                    yay -S --needed --noconfirm xcursor-dmz
                    ;;
            esac
            ;;
        "zypper")
            sudo zypper in -y dmz-icon-theme-cursors
            ;;
        *)
            yellow_message "Manual installation required."
            yellow_message "Download:" "https://github.com/rhizoome/dmz-cursors"
            return 0
            ;;
    esac

    green_message "Installed:" "DMZ cursor"
}
