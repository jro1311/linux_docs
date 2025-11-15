install_mpv() {
    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y mpv
            ;;
        "dnf")
            sudo dnf install -y mpv
            ;;
        "eopkg")
            sudo eopkg install -y mpv
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm mpv
            ;;
        "xbps")
            sudo xbps-install -Sy mpv
            ;;
        "zypper")
            sudo zypper in -y mpv
            ;;
        *)
            if [[ "$flatpak_installed" -eq 1 ]]; then
                flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
                flatpak install flathub -y io.mpv.Mpv

            elif [[ "$snap_installed" -eq 1 ]]; then
                sudo snap install mpv

            else
                unsupported_package_manager
                return 1
            fi
            ;;
    esac

    mkdir -pv "$HOME/.config/mpv"
    mkdir -pv "$HOME/.var/app/io.mpv.Mpv/config/mpv"
    cp -vr "$HOME/Documents/linux_docs/configs/applications/mpv" "$HOME/.config/"
    cp -vr "$HOME/Documents/linux_docs/configs/applications/mpv" "$HOME/.var/app/io.mpv.Mpv/config/"

    # Edits mpv profile from high quality to fast
    if [ "$host_system" = "laptop" ]; then
        sed -i 's/profile=high-quality/profile=fast/' "$HOME/.config/mpv/mpv.conf"
        sed -i 's/profile=high-quality/profile=fast/' "$HOME/.var/app/io.mpv.Mpv/config/mpv/mpv.conf"
    fi

    green_message "mpv is now installed."
}

install_spotify() {
    case "$primary_package_manager" in
        "apt")
            curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
            echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
            sudo apt-get update && sudo apt-get install -y spotify-client
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm spotify-launcher
            ;;
        *)
            if [[ "$flatpak_installed" -eq 1 ]]; then
                flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
                flatpak install flathub -y com.spotify.Client

            elif [[ "$snap_installed" -eq 1 ]]; then
                sudo snap install spotify

            else
                unsupported_package_manager
                return 1
            fi
            ;;
    esac

    green_message "Spotify is now installed."
}
