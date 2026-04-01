install_discord() {
    source_system_info
    case "$primary_package_manager" in
        "apt")
            wget -O "$HOME/Downloads/discord.deb" "https://discord.com/api/download?platform=linux&format=deb"
            sudo apt-get install -y "$HOME/Downloads/discord.deb"
            rm -v "$HOME/Downloads/discord.deb"
            ;;
        "dnf")
            sudo dnf install -y discord
            ;;
        "eopkg")
            sudo eopkg install -y discord
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm discord
            ;;
        "zypper")
            sudo zypper in -y discord
            ;;
        *)
            if [ "$flatpak_installed" -eq 1 ]; then
                flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
                flatpak install flathub -y com.discordapp.Discord

            elif [ "$snap_installed" -eq 1 ]; then
                sudo snap install discord

            else
                unsupported_package_manager
                return 1
            fi
            ;;
    esac

    green_message "Discord is now installed."
}
