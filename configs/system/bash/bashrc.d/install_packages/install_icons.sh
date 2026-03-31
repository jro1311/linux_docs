install_icons_elementary() {
    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y elementary-icon-theme
            ;;
        "dnf")
            sudo dnf install -y elementary-icon-theme
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm elementary-icon-theme
            ;;
        "zypper")
            sudo zypper in -y pantheon-icons
            ;;
        "rpm-ostree")
            inverse_check elementary-icon-theme \
                sudo rpm-ostree install elementary-icon-theme
            ;;
        *)
            yellow_message "Manual installation required."
            yellow_message "Download:" "https://github.com/shimmerproject/elementary-xfce"
            return 0
            ;;
    esac

    green_message "Elementary icons are now installed."
}
