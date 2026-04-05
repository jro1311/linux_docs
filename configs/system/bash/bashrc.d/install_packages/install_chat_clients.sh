# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

install_discord() {
    detect_system
    package_installed=0
    case "$primary_package_manager" in
        "apt")
            wget -O "$HOME/Downloads/discord.deb" "https://discord.com/api/download?platform=linux&format=deb"
            sudo apt-get install -y "$HOME/Downloads/discord.deb" && package_installed=1
            rm -v "$HOME/Downloads/discord.deb"
            ;;
        "dnf"|"eopkg"|"pacman"|"zypper")
            install_packages "discord" && package_installed=1
            ;;
    esac

    if [ "$package_installed" -eq 0 ]; then
        if [ "$flatpak_installed" -eq 1 ]; then
            flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
            flatpak install flathub -y com.discordapp.Discord

        elif [ "$snap_installed" -eq 1 ]; then
            sudo snap install discord

        else
            unsupported_package_manager
            return 1
        fi
    fi

    green_message "Installed:" "Discord"
}
