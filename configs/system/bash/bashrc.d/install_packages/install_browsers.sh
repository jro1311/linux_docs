install_brave() {
    detect_system
    curl -fsS https://dl.brave.com/install.sh | sh

    if ! command -v brave-browser >/dev/null 2>&1; then
        if [ "$flatpak_installed" -eq 1 ]; then
            flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
            flatpak install flathub -y com.brave.Browser

        elif [ "$snap_installed" -eq 1 ]; then
            sudo snap install brave
        else
            unsupported_package_manager
            return 1
        fi
    fi

    green_message "Installed:" "Brave"
}

install_librewolf() {
    detect_system
    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y extrepo
            sudo extrepo enable librewolf
            sudo apt-get update && sudo apt-get install -y librewolf
            ;;
        "dnf")
            curl -fsSL https://repo.librewolf.net/librewolf.repo | pkexec tee /etc/yum.repos.d/librewolf.repo
            sudo dnf install -y librewolf
            ;;
        "pacman")
            case "$secondary_package_manager" in
                "paru"|"yay")
                    "$secondary_package_manager" -S --needed --noconfirm librewolf-bin
                    ;;
                *)
                    install_yay
                    yay -S --needed --noconfirm librewolf-bin
                    ;;
            esac
            ;;
        *)
            if [[ "$flatpak_installed" -eq 1 ]]; then
                flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
                flatpak install flathub -y io.gitlab.librewolf-community

            else
                unsupported_package_manager
                return 1
            fi
            ;;
    esac

    green_message "Installed:" "LibreWolf"
}

install_ungoogled_chromium() {
    detect_system
    case "$primary_package_manager" in
        "dnf")
            sudo dnf copr enable -y wojnilowicz/ungoogled-chromium
            sudo dnf install -y ungoogled-chromium
            ;;
        "pacman")
            case "$secondary_package_manager" in
                "paru"|"yay")
                    "$secondary_package_manager" -S --needed --noconfirm ungoogled-chromium-bin
                    ;;
                *)
                    install_yay
                    yay -S --needed --noconfirm ungoogled-chromium-bin
                    ;;
            esac
            ;;
        *)
            if [[ "$flatpak_installed" -eq 1 ]]; then
                flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
                flatpak install flathub -y io.github.ungoogled_software.ungoogled_chromium

            else
                unsupported_package_manager
                return 1
            fi
            ;;
    esac

    green_message "Installed:" "Ungoogled Chromium"
}
