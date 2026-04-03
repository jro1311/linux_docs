install_cursor_bibata() {
    source_system_info
    case "$primary_package_manager" in
        "dnf")
            case "$os" in
                "openmandriva")
                    ;;
                *)
                    sudo dnf config-manager addrepo https://terra.fyralabs.com/terra.repo
                    ;;
            esac
        ;;
    esac

    declare -A bibata=(
        [apt]="bibata-cursor-theme"
        [dnf]="bibata-cursor-theme"
        [eopkg]="bibata-cursors"
        [pacman]="bibata-cursor-theme"
    )

    package_installed=0
    if ! install_packages ${bibata[$primary_package_manager]}; then
        yellow_message "Manual installation required."
        yellow_message "Download:" "https://github.com/ful1e5/Bibata_Cursor"
        return 0
    fi

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
