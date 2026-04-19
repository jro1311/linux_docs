# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

install_mpv() {
    detect_system
    package_installed=0
    if [ "$primary_pm" != "rpm-ostree" ]; then
        install_packages "mpv" && package_installed=1
    fi

    if [ "$package_installed" -eq 0 ]; then
        if [ "$flatpak_installed" -eq 1 ]; then
            flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
            flatpak install flathub -y io.mpv.Mpv

        elif [ "$snap_installed" -eq 1 ]; then
            sudo snap install mpv
        else
            unsupported_package_manager
            return 1
        fi
    fi

    mkdir -pv "$HOME/.config/mpv"
    mkdir -pv "$HOME/.var/app/io.mpv.Mpv/config/mpv"
    cp -vr "$HOME/Documents/linux_docs/configs/applications/mpv" "$HOME/.config/"
    cp -vr "$HOME/Documents/linux_docs/configs/applications/mpv" "$HOME/.var/app/io.mpv.Mpv/config/"

    # Switches mpv profile from high-quality to fast when on battery
    if [ "$battery_detected" -eq 1 ]; then
        sed -i 's/profile=high-quality/profile=fast/' "$HOME/.config/mpv/mpv.conf"
        sed -i 's/profile=high-quality/profile=fast/' "$HOME/.var/app/io.mpv.Mpv/config/mpv/mpv.conf"
    fi

    green_message "Installed:" "mpv"
}

install_spotify() {
    detect_system
    case "$primary_pm" in
        "apt")
            curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
            echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
            sudo apt-get update && sudo apt-get install -y spotify-client
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm spotify-launcher
            ;;
        *)
            if [ "$flatpak_installed" -eq 1 ]; then
                flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
                flatpak install flathub -y com.spotify.Client

            elif [ "$snap_installed" -eq 1 ]; then
                sudo snap install spotify

            else
                unsupported_package_manager
                return 1
            fi
            ;;
    esac

    green_message "Installed:" "Spotify"
}
