install_theme_greybird() {
    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y greybird-gtk-theme
            ;;
        "dnf")
            case "$os" in
                "openmandriva")
                    yellow_message "Manual installation required. Download: https://github.com/shimmerproject/Greybird"
                    return 0
                    ;;
                *)
                    sudo dnf install -y greybird-dark-theme greybird-light-theme
                    ;;
            esac
            ;;
        "pacman")
            case "$secondary_package_manager" in
                "paru"|"yay")
                    "$secondary_package_manager" -S --needed --noconfirm xfce-theme-greybird
                    ;;
                *)
                    install_yay
                    yay -S --needed --noconfirm xfce-theme-greybird
                    ;;
            esac
            ;;
        xbps)
            sudo xbps-install -Sy greybird-themes
            ;;
        "zypper")
            sudo zypper in -y metatheme-greybird-common
            ;;
        "rpm-ostree")
            inverse_check greybird-dark-theme || inverse_check greybird-light-theme \
                sudo rpm-ostree install greybird-dark-theme greybird-light-theme
            ;;
        *)
            yellow_message "Manual installation required. Download: https://github.com/shimmerproject/Greybird"
            return 0
            ;;
    esac

    green_message "Greybird theme is now installed."
}

