install_btop() {
    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y btop rocm-smi
            ;;
        "dnf")
            sudo dnf install -y btop rocm-smi
            ;;
        "eopkg")
            sudo eopkg install -y btop rocm-smi
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm btop rocm-smi-lib
            ;;
        "xbps")
            sudo xbps-install -Sy btop ROCm-SMI
            ;;
        "zypper")
            sudo zypper in -y btop
            ;;
        "rpm-ostree")
            inverse_check btop \
                sudo rpm-ostree install btop rocm-smi
            ;;
        *)
            if [[ "$snap_installed" -eq 1 ]]; then
                sudo snap install btop
            else
                unsupported_package_manager
                return 1
            fi
    esac

    mkdir -pv "$HOME/.config/btop"
    cp -v "$HOME/Documents/linux_docs/configs/applications/btop.conf" "$HOME/.config/btop/"

    green_message "btop is now installed."
}

install_distrobox() {
    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y distrobox podman
            ;;
        "dnf")
            sudo dnf install -y distrobox podman
            ;;
        "eopkg")
            sudo eopkg install -y distrobox podman
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm distrobox podman
            ;;
        "zypper")
            sudo zypper in -y distrobox podman
            ;;
        "rpm-ostree")
            inverse_check distrobox || inverse_check podman \
                sudo rpm-ostree install distrobox podman
                reboot_required
                return 0
            ;;
        *)
            unsupported_package_manager
            return 1
            ;;
    esac

    case $os in
        "arch")
            distrobox-create "$os" -i arch:latest
            ;;
        "debian")
            distrobox-create "$os" -i debian:latest
            ;;
        "fedora")
            distrobox-create "$os" -i fedora:latest
            ;;
        "opensuse")
            distrobox-create "$os" -i opensuse:latest
            ;;
        "ubuntu")
            distrobox-create "$os" -i ubuntu:latest
            ;;
        *)
            case "$os_like" in
                "debian")
                    distrobox-create "$os" -i debian:latest
                    ;;
                "ubuntu debian")
                    distrobox-create "$os" -i ubuntu:latest
                    ;;
                "fedora")
                    distrobox-create "$os" -i fedora:latest
                    ;;
                *)
                    distrobox-create arch -i arch:latest
                    ;;
            esac
    esac

    green_message "Distrobox is now installed."
}

install_flatpak() {
    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y flatpak
            ;;
        "dnf")
            sudo dnf install -y flatpak
            ;;
        "eopkg")
            sudo eopkg install -y flatpak
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm flatpak
            ;;
        "xbps")
            sudo xbps-install -Sy flatpak
            ;;
        "zypper")
            sudo zypper in -y flatpak
            ;;
        "rpm-ostree")
            inverse_check flatpak \
                sudo rpm-ostree install flatpak
                reboot_required
                return 0
            ;;
        *)
            unsupported_package_manager
            return 1
            ;;
    esac

    if getent group wheel >/dev/null 2>&1; then
        sudo usermod -aG wheel "$USER"
        echo "${green}'$USER' added to 'wheel' group. ${reset}"
    fi

    if flatpak remote-list | grep -Fq "fedora"; then
        flatpak remote-modify --disable fedora
        echo "${green}Flatpak: Disabled Fedora repository ${reset}"
    else
        echo "${yellow}Flatpak: No Fedora repository detected ${reset}"
    fi

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    green_message "Flatpak is now installed."
}

install_htop() {
    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y htop
            ;;
        "dnf")
            sudo dnf install -y htop
            ;;
        "eopkg")
            sudo eopkg install -y htop
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm htop
            ;;
        "xbps")
            sudo xbps-install -Sy htop
            ;;
        "zypper")
            sudo zypper in -y htop
            ;;
        "rpm-ostree")
            inverse_check \
                sudo rpm-ostree install htop
            ;;
        *)
            if [[ "$snap_installed" -eq 1 ]]; then
                sudo snap install htop
            else
                unsupported_package_manager
                return 1
            fi
    esac

    mkdir -pv "$HOME/.config/htop"
    cp -v "$HOME/Documents/linux_docs/configs/applications/htoprc" "$HOME/.config/htop/"

    green_message "htop is now installed."
}

install_snap() {
    if [ "$init_system" != "systemd" ]; then
        unsupported_init_system
        return 1
    fi

    case "$primary_package_manager" in
        "apt")
            # Unlocks package(s) if they are locked
            if apt-mark showhold | grep -q "^snapd$"; then
                sudo apt-mark unhold snapd
            fi

            sudo apt-get install -y snapd
            sudo snap install snapd
            ;;
        "dnf")
            sudo dnf install -y snapd
            ;;
        "eopkg")
            sudo eopkg install -y snapd
            ;;
        "pacman")
            case "$secondary_package_manager" in
                "paru"|"yay")
                    "$secondary_package_manager" -S --needed --noconfirm snapd
                    ;;
                *)
                    install_paru
                    paru -S --needed --noconfirm snapd
                    ;;
            esac
            ;;
        "zypper")
            case "$os" in
                "opensuse-tumbleweed"|"opensuse-slowroll")
                    sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Tumbleweed snappy
                    ;;
                "opensuse-leap")
                    sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Leap_16.0 snappy
                    ;;
                *)
                    unsupported_operating_system
                    return 1
                    ;;
            esac
            sudo zypper --gpg-auto-import-keys refresh
            sudo zypper ref && sudo zypper in -y snapd
            ;;
        *)
            unsupported_package_manager
            return 1
            ;;
    esac

    sudo systemctl enable --now snapd

    # Enables classic snap support
    sudo ln -s /var/lib/snapd/snap /snap

    sudo snap install snap-store

    green_message "Snap is now installed."
}

install_toolbox() {
    case "$primary_package_manager" in
        "dnf")
            sudo dnf install -y toolbox podman
            ;;
        "rpm-ostree")
            inverse_check toolbox || inverse_check podman \
                sudo rpm-ostree install toolbox podman
                reboot_required
                return 0
            ;;
        *)
            unsupported_package_manager
            return 1
            ;;
    esac

    case $os in
        "fedora")
            toolbox create --distro fedora --release "$fedora_version"
            ;;
    esac

    green_message "Toolbox is now installed."
}
