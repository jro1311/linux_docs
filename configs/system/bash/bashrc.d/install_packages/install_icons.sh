install_icons_elementary() {
    source_system_info
    declare -A elementary_icons=(
        [apt]="elementary-icon-theme"
        [dnf]="elementary-icon-theme"
        [pacman]="elementary-icon-theme"
        [zypper]="pantheon-icons"
        [rpm-ostree]="elementary-icon-theme"
    )

    if ! install_packages "${elementary_icons[$primary_package_manager]}"; then
        yellow_message "Manual installation required."
        yellow_message "Download:" "https://github.com/shimmerproject/elementary-xfce"
        return 0
    fi

    green_message "Installed:" "Elementary icons"
}
