install_btop() {
    detect_system
    if ! install_packages "btop"; then
        if [ "$snap_installed" -eq 1 ]; then
            sudo snap install btop
        else
            unsupported_package_manager
            return 1
        fi
    fi

    declare -A rocm_smi=(
        [apt]="rocm-smi"
        [dnf]="rocm-smi"
        [eopkg]="rocm-smi"
        [pacman]="rocm-smi-lib"
        [xbps]="ROCm-SMI"
        [rpm-ostree]="rocm-smi"
    )

    install_packages "${rocm_smi[$primary_package_manager]}"

    mkdir -pv "$HOME/.config/btop"
    cp -v "$HOME/Documents/linux_docs/configs/applications/btop.conf" "$HOME/.config/btop/"

    green_message "Installed:" "btop"
}

install_distrobox() {
    detect_system
    install_packages "distrobox" "podman"
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

    green_message "Installed:" "distrobox"
}

install_flatpak() {
    detect_system
    install_packages "flatpak"

    if getent group wheel >/dev/null 2>&1; then
        sudo usermod -aG wheel "$USER"
        green_message "'$USER' added to 'wheel' group."
    fi

    if flatpak remote-list | grep -Fq "fedora"; then
        flatpak remote-modify --disable fedora
        green_message "flatpak:" "Disabled Fedora repository"
    else
        yellow_message "flatpak:" "No Fedora repository detected."
    fi

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    green_message "Installed:" "flatpak"
}

install_htop() {
    detect_system
    if ! install_packages "htop"; then
        if [ "$snap_installed" -eq 1 ]; then
            sudo snap install htop
        else
            unsupported_package_manager
            return 1
        fi
    fi

    mkdir -pv "$HOME/.config/htop"
    cp -v "$HOME/Documents/linux_docs/configs/applications/htoprc" "$HOME/.config/htop/"

    green_message "Installed:" "htop"
}

install_snap() {
    detect_system
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
                    install_yay
                    yay -S --needed --noconfirm snapd
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

    green_message "Installed:" "snap"
}

install_toolbox() {
    detect_system
    case "$primary_package_manager" in
        "dnf")
            sudo dnf install -y toolbox podman
            ;;
        "rpm-ostree")
            inverse_check toolbox \
                sudo rpm-ostree install toolbox
                reboot_required
                return 0
            inverse_check podman \
                sudo rpm-ostree install podman
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

    green_message "Installed:" "toolbox"
}
