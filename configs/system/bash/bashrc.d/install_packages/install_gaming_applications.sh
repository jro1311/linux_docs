install_corectrl() {
    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y corectrl
            ;;
        "dnf")
            sudo dnf install -y corectrl
            ;;
        "eopkg")
            sudo eopkg install -y corectrl
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm corectrl
            ;;
        "xbps")
            sudo xbps-install -Sy corectrl
            ;;
        "zypper")
            case "$os" in
                "opensuse-tumbleweed")
                    sudo zypper addrepo https://download.opensuse.org/repositories/home:Dead_Mozay/openSUSE_Tumbleweed/home:Dead_Mozay.repo
                    sudo zypper ref && sudo zypper in -y corectrl
                    ;;
                "opensuse-slowroll")
                    sudo zypper addrepo https://download.opensuse.org/repositories/home:Dead_Mozay/openSUSE_Slowroll/home:Dead_Mozay.repo
                    sudo zypper ref && sudo zypper in -y corectrl
                    ;;
                *)
                    unsupported_operating_system
                    return 1
                    ;;
            esac
            ;;
        "rpm-ostree")
            inverse_check corectrl \
                sudo rpm-ostree install corectrl
                reboot_required
                return 0
            ;;
        *)
            unsupported_package_manager
            return 1
            ;;
    esac

    # Creates a polkit rule file with the current user's primary group
    sudo mkdir -pv /etc/polkit-1/rules.d
    sudo tee /etc/polkit-1/rules.d/90-corectrl.rules << EOF
    polkit.addRule(function(action, subject) {
        if ((action.id == 'org.corectrl.helper.init' ||
            action.id == 'org.corectrl.helperkiller.init') &&
            subject.local == true &&
            subject.active == true &&
            subject.isInGroup("$group")) {
                return polkit.Result.YES;
        }
    });
EOF
    if echo "$gpu_info" | grep -Fiq "amd"; then
        green_message "Detected GPU: AMD"
        add_kernel_argument "amdgpu.ppfeaturemask=0xffffffff"
    else
        yellow_message "No AMD GPU detected."
    fi

    mkdir -pv "$HOME/.config/autostart"
    cp -v /usr/share/applications/org.corectrl.*.desktop "$HOME/.config/autostart/org.corectrl.CoreCtrl.desktop"

    green_message "CoreCtrl is now installed."
}

install_lact() {
    case "$primary_package_manager" in
        "dnf")
            sudo dnf copr enable -y ilyaz/LACT
            sudo dnf install -y lact
            ;;
        "eopkg")
            sudo eopkg install -y lact
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm lact
            ;;
        "xbps")
            sudo xbps-install -Sy LACT
            ;;
        *)
            if [ "$flatpak_installed" -eq 1 ]; then
                flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
                flatpak install flathub -y io.github.ilya_zlobintsev.LACT
            else
                unsupported_package_manager
                return 1
            fi
            ;;
    esac

    case "$init_system" in
        "systemd")
            sudo systemctl enable --now lactd
            ;;
        "runit")
            sudo ln -s /etc/sv/lactd /var/service
            ;;
        *)
            unsupported_init_system
            return 1
            ;;
    esac

    if echo "$gpu_info" | grep -Fiq "amd"; then
        green_message "Detected GPU: AMD"
        add_kernel_argument "amdgpu.ppfeaturemask=0xffffffff"
    else
        yellow_message "No AMD GPU detected."
    fi

    green_message "LACT is now installed."
}

install_mangohud() {
    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y mangohud
            ;;
        "dnf")
            sudo dnf install -y mangohud
            ;;
        "eopkg")
            sudo eopkg install -y mangohud
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm mangohud lib32-mangohud
            ;;
        "xbps")
            sudo xbps-install -Sy MangoHud MangoHud-32bit
            ;;
        "rpm-ostree")
            ;;
        *)
            unsupported_package_manager
            return 1
            ;;
    esac

    if [[ "$flatpak_installed" -eq 1 ]]; then
        flatpak install flathub runtime/org.freedesktop.Platform.VulkanLayer.MangoHud
    fi

    mkdir -pv "$HOME/.config/MangoHud"
    mkdir -pv "$HOME/Documents/mangohud/logs"
    cp -v "$HOME/Documents/linux_docs/configs/applications/MangoHud.conf" "$HOME/.config/MangoHud/"

    if [ "$host_system" = "laptop" ]; then

        # Edits FPS limits
        sed -i 's/fps_limit=160,120,90,60,30,0/fps_limit=60,30,0/' "$HOME/.config/MangoHud/MangoHud.conf"

    fi

    if ! grep -Fq "output_folder" "$HOME/.config/MangoHud/MangoHud.conf"; then
        echo "output_folder=$HOME/Documents/mangohud/logs" >> "$HOME/.config/MangoHud/MangoHud.conf"
    fi

    green_message "MangoHud is now installed."
}

install_minecraft() {
    case "$primary_package_manager" in
        "apt")
            wget -O "$HOME/Downloads/Minecraft.deb" "https://launcher.mojang.com/download/Minecraft.deb"
            sudo apt-get install -y "$HOME/Downloads/Minecraft.deb"
            rm -v "$HOME/Downloads/Minecraft.deb"
            ;;
        "pacman")
            enable_chaotic_aur
            case "$secondary_package_manager" in
                "paru"|"yay")
                    "$secondary_package_manager" -S --needed --noconfirm minecraft-launcher
                    ;;
                *)
                    install_paru
                    paru -S --needed --noconfirm minecraft-launcher
                    ;;
            esac
            ;;
        *)
            wget -O "$HOME/Downloads/Minecraft.tar.gz" "https://launcher.mojang.com/download/Minecraft.tar.gz"
            tar -xvf "$HOME/Downloads/Minecraft.tar.gz" -C "$HOME/Downloads/"
            rm -v "$HOME/Downloads/Minecraft.tar.gz"
            ;;
    esac

    green_message "Minecraft is now installed."
}

install_proton_ge() {
    echo "Creating temporary working directory..."
    rm -rf /tmp/proton-ge-custom
    mkdir /tmp/proton-ge-custom
    cd /tmp/proton-ge-custom

    echo "Fetching tarball URL..."
    tarball_url=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .tar.gz)
    tarball_name=$(basename "$tarball_url")
    echo "Downloading tarball: $tarball_name..."
    curl -# -L "$tarball_url" -o "$tarball_name" --no-progress-meter

    echo "Fetching checksum URL..."
    checksum_url=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .sha512sum)
    checksum_name=$(basename "$checksum_url")
    echo "Downloading checksum: $checksum_name..."
    curl -# -L "$checksum_url" -o "$checksum_name" --no-progress-meter

    echo "Verifying tarball $tarball_name with checksum $checksum_name..."
    sha512sum -c "$checksum_name"

    if command -v steam >/dev/null 2>&1; then
        mkdir -pv "$HOME/.steam/steam/compatibilitytools.d"
        tar -xfv "$tarball_name" -C "$HOME/.steam/steam/compatibilitytools.d/"

    elif flatpak list --columns=application | grep -Fiq "com.valvesoftware.Steam"; then
        mkdir -pv "$HOME/.var/app/com.valvesoftware.Steam/data/Steam/compatibilitytools.d"
        tar -xfv "$tarball_name" -C "$HOME/.var/app/com.valvesoftware.Steam/data/Steam/compatibilitytools.d/"

    else
        red_message "Steam not detected."
        return 1
    fi

    green_message "Proton GE is now installed. Restart Steam to enable."
}

install_waydroid() {
    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y curl ca-certificates
            curl -s https://repo.waydro.id | sudo bash
            sudo apt-get install -y waydroid
            ;;
        "dnf")
            sudo dnf install -y waydroid
            echo "System OTA: https://ota.waydro.id/system"
            echo "Vendor OTA: https://ota.waydro.id/vendor"
            ;;
        "eopkg")
            sudo eopkg install -y waydroid
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm waydroid
            ;;
        "xbps")
            sudo xbps-install -Sy waydroid python3-pyclip wl-clipboard
            ;;
        "rpm-ostree")
            inverse_check waydroid \
                sudo rpm-ostree install waydroid
                reboot_required
                return 0
            ;;
        *)
            unsupported_package_manager
            return 1
            ;;
    esac

    sudo waydroid init

    case "$init_system" in
        "systemd")
            sudo systemctl enable --now waydroid-container
            ;;
        "runit")
            sudo ln -s /etc/sv/waydroid-container /var/service
            ;;
        *)
            unsupported_init_system
            return 1
    esac

    green_message "Waydroid is now installed."
}

install_gaming_meta() {
    auto_gaming_flatpaks=(
    "com.geeks3d.furmark"
    "com.github.Matoking.protontricks"
    "com.heroicgameslauncher.hgl"
    "com.vysp3r.ProtonPlus"
    "org.prismlauncher.PrismLauncher"
    )

    manual_gaming_flatpaks=(
    "org.freedesktop.Platform.VulkanLayer.MangoHud"
    )

    case "$primary_package_manager" in
        "apt")
            # Enables 32-bit libraries
            sudo dpkg --add-architecture i386 && sudo apt-get update
            sudo apt-get install -y steam-installer
            ;;
        "dnf")
            sudo dnf install -y steam
            ;;
        "eopkg")
            sudo eopkg install -y steam
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm steam
            ;;
        "xbps")
            sudo xbps-install -Sy steam
            ;;
        "zypper")
            sudo zypper in -y steam selinux-policy-targeted-gaming
            ;;
        "rpm-ostree")
            ;;
        *)
            unsupported_package_manager
            exit 1
            ;;
    esac

    install_mangohud
    install_corectrl

    if [ "$flatpak_installed" -eq 1 ]; then
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

        if [ "$primary_package_manager" = "rpm-ostree" ]; then
            flatpak install flathub -y com.valvesoftware.Steam
        fi

        flatpak install flathub -y "${auto_gaming_flatpaks[@]}"
        flatpak install flathub "${manual_gaming_flatpaks[@]}"

        # Grants flatpaks read-only access to MangoHud's config file
        flatpak override --user --filesystem=xdg-config/MangoHud:ro com.geeks3d.furmark
        flatpak override --user --filesystem=xdg-config/MangoHud:ro com.heroicgameslauncher.hgl
        flatpak override --user --filesystem=xdg-config/MangoHud:ro org.prismlauncher.PrismLauncher
    fi

    green_message "Gaming packages are now installed."
}
