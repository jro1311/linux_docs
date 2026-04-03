install_corectrl() {
    source_system_info
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
    sudo tee /etc/polkit-1/rules.d/90-corectrl.rules <<-EOF
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
        add_kernel_parameter "amdgpu.ppfeaturemask=0xffffffff"
    else
        yellow_message "No AMD GPU detected."
    fi

    mkdir -pv "$HOME/.config/autostart"
    cp -v /usr/share/applications/org.corectrl.*.desktop "$HOME/.config/autostart/org.corectrl.CoreCtrl.desktop"

    green_message "CoreCtrl is now installed."
}

install_lact() {
    source_system_info
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
        "dinit")
            sudo ln -s /etc/dinit.d/lactd /etc/dinit.d/boot.d/
            ;;
        "openrc")
            sudo rc-service lactd start
            sudo rc-update add lactd
            ;;
        "runit")
            sudo ln -s /etc/sv/lactd /var/service
            ;;
        "s6")
            sudo ln -s /etc/s6/sv/lactd /var/service/
            ;;
        "sysvinit")
            sudo update-rc.d lactd enable
            sudo service lactd start
            ;;
        *)
            unsupported_init_system
            return 1
            ;;
    esac

    if echo "$gpu_info" | grep -Fiq "amd"; then
        green_message "Detected GPU: AMD"
        add_kernel_parameter "amdgpu.ppfeaturemask=0xffffffff"
    else
        yellow_message "No AMD GPU detected."
    fi

    green_message "LACT is now installed."
}

install_mangohud() {
    source_system_info
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

    if [ "$flatpak_installed" -eq 1 ]; then
        flatpak install flathub -y org.freedesktop.Platform.VulkanLayer.MangoHud
    else
        install_flatpak && flatpak_installed=1
        flatpak install flathub -y org.freedesktop.Platform.VulkanLayer.MangoHud
    fi

    mkdir -pv "$HOME/.config/MangoHud"
    mkdir -pv "$HOME/Documents/mangohud/logs"
    cp -v "$HOME/Documents/linux_docs/configs/applications/MangoHud.conf" "$HOME/.config/MangoHud/"

    if [ "$display_cmd" = "unknown" ]; then
        read -er -p "Enter display refresh rate: " refresh_rate

        if [ -z "$refresh_rate" ]; then
            red_message "Error:" "'$refresh_rate' is empty"
            return 1
        fi

        max_fps_target=$(awk "BEGIN {printf \"%.0f\", int(($refresh_rate - 5) / 10 + 0.5) * 10}")
    fi

    if [ "$refresh_rate" -le 55 ]; then
        fps_list="$max_fps_target,0"

    elif [ "$refresh_rate" -le 60 ]; then
        fps_list="$max_fps_target,30,0"

    elif [ "$refresh_rate" -le 75 ]; then
        fps_list="$max_fps_target,60,30,0"

    elif [ "$refresh_rate" -le 90 ]; then
        fps_list="$max_fps_target,75,60,30,0"

    elif [ "$refresh_rate" -le 100 ]; then
        fps_list="$max_fps_target,90,75,60,30,0"

    elif [ "$refresh_rate" -le 120 ]; then
        fps_list="$max_fps_target,100,90,75,60,30,0"

    elif [ "$refresh_rate" -le 180 ]; then
        fps_list="$max_fps_target,120,100,90,75,60,30,0"

    elif [ "$refresh_rate" -le 240 ]; then
        fps_list="$max_fps_target,180,120,100,90,75,60,30,0"

    elif [ "$refresh_rate" -le 360 ]; then
        fps_list="$max_fps_target,240,180,120,100,90,75,60,30,0"

    elif [ "$refresh_rate" -le 480 ]; then
        fps_list="$max_fps_target,360,240,180,120,100,90,75,60,30,0"

    elif [ "$refresh_rate" -gt 480 ]; then
        fps_list="$max_fps_target,480,360,240,180,120,100,90,75,60,30,0"
    fi

    sed -i "s/^fps_limit=/fps_limit=$fps_list/" "$HOME/.config/MangoHud/MangoHud.conf"

    if ! grep -Fq "output_folder" "$HOME/.config/MangoHud/MangoHud.conf"; then
        echo "output_folder=$HOME/Documents/mangohud/logs" >> "$HOME/.config/MangoHud/MangoHud.conf"
    fi

    green_message "MangoHud is now installed."
}

install_minecraft() {
    source_system_info
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
                    install_yay
                    yay -S --needed --noconfirm minecraft-launcher
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

    # Define path prefix
    if command -v /usr/bin/steam >/dev/null 2>&1; then
        path_prefix="$HOME/.local/share/Steam/compatibilitytools.d/"

    elif command -v flatpak >/dev/null 2>&1 && flatpak list --app --columns=app | grep -Fiq "com.valvesoftware.Steam"; then
        path_prefix="$HOME/.var/app/com.valvesoftware.Steam/data/Steam/compatibilitytools.d/"

    elif command -v /snap/bin/steam >/dev/null 2>&1; then
        path_prefix="$HOME/snap/steam/common/.steam/steam/compatibilitytools.d/"

    else
        red_message "Steam not detected."
        return 1
    fi

    mkdir -pv "$path_prefix"
    tar -xfv "$tarball_name" -C "$path_prefix"

    green_message "Proton GE is now installed. Restart Steam to enable."
}

install_waydroid() {
    source_system_info
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
        "dinit")
            sudo ln -s /etc/dinit.d/waydroid-container /etc/dinit.d/boot.d/
            ;;
        "openrc")
            sudo rc-service waydroid-container start
            sudo rc-update add waydroid-container
            ;;
        "runit")
            sudo ln -s /etc/sv/waydroid-container /var/service
            ;;
        "s6")
            sudo ln -s /etc/s6/sv/waydroid-container /var/service/
            ;;
        "sysvinit")
            sudo update-rc.d waydroid-container enable
            sudo service waydroid-container start
            ;;
        *)
            unsupported_init_system
            return 1
            ;;
    esac

    green_message "Waydroid is now installed."
}

install_gaming_meta() {
    source_system_info
    gaming_flatpaks=(
        "com.geeks3d.furmark"
        "com.github.Matoking.protontricks"
        "com.heroicgameslauncher.hgl"
        "com.vysp3r.ProtonPlus"
        "org.prismlauncher.PrismLauncher"
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
    install_lact

    if [ "$flatpak_installed" -eq 1 ]; then
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

        if [ "$primary_package_manager" = "rpm-ostree" ]; then
            flatpak install flathub -y com.valvesoftware.Steam
        fi

        flatpak install flathub -y "${gaming_flatpaks[@]}"

        # Grants flatpaks read-only access to MangoHud's config file
        flatpak override --user --filesystem=xdg-config/MangoHud:ro com.geeks3d.furmark
        flatpak override --user --filesystem=xdg-config/MangoHud:ro com.heroicgameslauncher.hgl
        flatpak override --user --filesystem=xdg-config/MangoHud:ro org.prismlauncher.PrismLauncher
    fi

    green_message "Gaming packages are now installed."
}
