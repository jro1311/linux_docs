install_micro() {
    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y micro
            ;;
        "dnf")
            sudo dnf install -y micro
            ;;
        "eopkg")
            sudo eopkg install -y micro
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm micro
            ;;
        "xbps")
            sudo xbps-install -Sy micro
            ;;
        "zypper")
            sudo zypper in -y micro-editor
            ;;
        "rpm-ostree")
            inverse_check \
                rpm-ostree install micro
            ;;
        *)
            if [[ "$snap_installed" -eq 1 ]]; then
                sudo snap install micro
            else
                unsupported_package_manager
                return 1
            fi
            ;;
    esac

    mkdir -pv "$HOME/.config/micro"
    cp -v "$HOME/Documents/linux_docs/configs/applications/micro/settings.json" "$HOME/.config/micro/"

    green_message "micro is now installed."
}

install_nano() {
    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y nano
            ;;
        "dnf")
            sudo dnf install -y nano
            ;;
        "eopkg")
            sudo eopkg install -y nano
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm nano
            case "$secondary_package_manager" in
                "paru"|"yay")
                    "$secondary_package_manager" -S --needed --noconfirm nano-syntax-highlighting
                    ;;
                *)
                    install_paru
                    paru -S --needed --noconfirm nano-syntax-highlighting
                    ;;
            esac
            ;;
        "xbps")
            sudo xbps-install -Sy nano
            ;;
        "zypper")
            sudo zypper in -y nano
            ;;
        "rpm-ostree")
            inverse_check nano \
                rpm-ostree install nano
            ;;
        *)
            if [[ "$snap_installed" -eq 1 ]]; then
                sudo snap install nano
            else
                unsupported_package_manager
                return 1
            fi
            ;;
    esac

    mkdir -pv "$HOME/.config/nano"
    cp -v "$HOME/Documents/linux_docs/configs/applications/nanorc" "$HOME/.config/nano/"
    sudo cp -v "$HOME/Documents/linux_docs/configs/applications/nanorc" /etc/nanorc

    green_message "nano is now installed."
}

install_onlyoffice() {
    case "$primary_package_manager" in
        "apt")
            local deb="$HOME/Downloads/onlyoffice.deb"
            wget -O "$deb" "https://github.com/ONLYOFFICE/DesktopEditors/releases/latest/download/onlyoffice-desktopeditors_amd64.deb"
            sudo apt-get install -y "$deb"
            rm -v "$deb"
            ;;
        "dnf")
            local rpm="$HOME/Downloads/onlyoffice.rpm"
            wget -O "$rpm" "https://github.com/ONLYOFFICE/DesktopEditors/releases/latest/download/onlyoffice-desktopeditors.x86_64.rpm"
            sudo dnf install -y "$rpm"
            rm -v "$rpm"
            ;;
        "pacman")
            enable_chaotic_aur
            case "$secondary_package_manager" in
                "paru"|"yay")
                    "$secondary_package_manager" -S --needed --noconfirm onlyoffice-bin
                    ;;
                *)
                    install_paru
                    paru -S --needed --noconfirm onlyoffice-bin
                    ;;
            esac
            ;;
        *)
            if [[ "$flatpak_installed" -eq 1 ]]; then
                flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
                flatpak install flathub -y org.onlyoffice.desktopeditors

            elif [[ "$snap_installed" -eq 1 ]]; then
                sudo snap install onlyoffice-desktopeditors

            else
                unsupported_package_manager
                return 1
            fi
            ;;
    esac

    green_message "OnlyOffice is now installed."
}

install_vscode() {
    case "$primary_package_manager" in
        "apt")
            local deb="$HOME/Downloads/vscode.deb"
            wget -O "$deb" "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
            sudo apt-get install -y "$deb"
            rm -v "$deb"
            ;;
        "dnf")
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
            echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" \
                | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null
            sudo dnf check-upgrade && sudo dnf install -y code
            ;;
        "pacman")
            case "$secondary_package_manager" in
                "paru"|"yay")
                    "$secondary_package_manager" -S --needed --noconfirm visual-studio-code-bin
                    ;;
                *)
                    install_paru
                    paru -S --needed --noconfirm visual-studio-code-bin
                    ;;
            esac
            ;;
        "xbps")
            sudo xbps-install -Sy vscode
            ;;
        "zypper")
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
            echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" \
                | sudo tee /etc/zypp/repos.d/vscode.repo >/dev/null
            sudo zypper ref && sudo zypper in -y code
            ;;
        *)
            if [[ "$flatpak_installed" -eq 1 ]]; then
                flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
                flatpak install flathub -y com.visualstudio.code

            elif [[ "$snap_installed" -eq 1 ]]; then
                sudo snap install code --classic

            else
                unsupported_package_manager
                return 1
            fi
            ;;
    esac

    green_message "Visual Studio Code is now installed."
}

install_vscodium() {
    case "$primary_package_manager" in
        "apt")
            sudo wget https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
                -O /usr/share/keyrings/vscodium-archive-keyring.asc
            echo 'deb [ arch=amd64 signed-by=/usr/share/keyrings/vscodium-archive-keyring.asc ] https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs vscodium main' \
                | sudo tee /etc/apt/sources.list.d/vscodium.list
            sudo apt-get refresh && sudo apt-get install -y codium
            ;;
        "dnf")
            sudo tee -a /etc/yum.repos.d/vscodium.repo <<-'EOF'
            [gitlab.com_paulcarroty_vscodium_repo]
            name=gitlab.com_paulcarroty_vscodium_repo
            baseurl=https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/
            enabled=1
            gpgcheck=1
            repo_gpgcheck=1
            gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
            metadata_expire=1h
EOF
            sudo dnf check-upgrade && sudo dnf install -y codium
            ;;
        "pacman")
            case "$secondary_package_manager" in
                "paru"|"yay")
                    "$secondary_package_manager" -S --needed --noconfirm vscodium-bin
                    ;;
                *)
                    install_paru
                    paru -S --needed --noconfirm vscodium-bin
                    ;;
            esac
            ;;
        "zypper")
            sudo tee -a /etc/zypp/repos.d/vscodium.repo <<-'EOF'
            [gitlab.com_paulcarroty_vscodium_repo]
            name=gitlab.com_paulcarroty_vscodium_repo
            baseurl=https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/
            enabled=1
            gpgcheck=1
            repo_gpgcheck=1
            gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
            metadata_expire=1h
EOF
            sudo zypper ref && sudo zypper in -y codium
            ;;
        *)
            if [[ "$flatpak_installed" -eq 1 ]]; then
                flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
                flatpak install flathub -y com.vscodium.codium

            elif [[ "$snap_installed" -eq 1 ]]; then
                sudo snap install codium --classic

            else
                unsupported_package_manager
                return 1
            fi
            ;;
    esac

    green_message "Visual Studio Codium is now installed."
}
