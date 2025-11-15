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
                exit 0
            ;;
        *)
            unsupported_package_manager
            return 1
            ;;
    esac

    # Creates a polkit rule file with the current user's primary group
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
    local gpu_karg="amdgpu.ppfeaturemask=0xffffffff"

    if echo "$gpu_info" | grep -Fiq "amd"; then
        green_message "Detected GPU: AMD"

        case "$primary_package_manager" in
            "rpm-ostree")
                if ! rpm-ostree kargs | grep -Fq "$gpu_karg"; then
                    sudo rpm-ostree kargs --append="$gpu_karg"
                    green_message "'$gpu_karg' added to kernel arguments."
                else
                    green_message "'$gpu_karg' is already part of kernel arguments."
                fi
                ;;
            *)
                case "$bootloader" in
                    "grub")
                        if ! grep -Fq "$gpu_karg" /etc/default/grub; then
                            sudo sed -i "s/\(GRUB_CMDLINE_LINUX=\"[^\"]*\)\"/\1 $gpu_karg\"/" /etc/default/grub
                            sudo bash -c "$update_bootloader"
                            green_message "'$gpu_karg' added to kernel arguments."
                        else
                            green_message "'$gpu_karg' is already part of kernel arguments."
                        fi
                        ;;
                    "limine")
                        if ! grep -Fq "$gpu_karg" /etc/default/limine; then
                            sudo sed -i "/^KERNEL_CMDLINE\[default\\]/ s/\"$/ $gpu_karg\"/" /etc/default/limine
                            sudo bash -c "$update_bootloader"
                            green_message "'$gpu_karg' added to kernel arguments."
                        else
                            green_message "'$gpu_karg' is already part of kernel arguments."
                        fi
                        ;;
                esac
                ;;
        esac

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

    local gpu_karg="amdgpu.ppfeaturemask=0xffffffff"

    if echo "$gpu_info" | grep -Fiq "amd"; then
        green_message "Detected GPU: AMD"

        case "$primary_package_manager" in
            "rpm-ostree")
                if ! rpm-ostree kargs | grep -Fq "$gpu_karg"; then
                    sudo rpm-ostree kargs --append="$gpu_karg"
                    green_message "'$gpu_karg' added to kernel arguments."
                else
                    green_message "'$gpu_karg' is already part of kernel arguments."
                fi
                ;;
            *)
                case "$bootloader" in
                    "grub")
                        if ! grep -Fq "$gpu_karg" /etc/default/grub; then
                            sudo sed -i "s/\(GRUB_CMDLINE_LINUX=\"[^\"]*\)\"/\1 $gpu_karg\"/" /etc/default/grub
                            sudo bash -c "$update_bootloader"
                            green_message "'$gpu_karg' added to kernel arguments."
                        else
                            green_message "'$gpu_karg' is already part of kernel arguments."
                        fi
                        ;;
                    "limine")
                        if ! grep -Fq "$gpu_karg" /etc/default/limine; then
                            sudo sed -i "/^KERNEL_CMDLINE\[default\\]/ s/\"$/ $gpu_karg\"/" /etc/default/limine
                            sudo bash -c "$update_bootloader"
                            green_message "'$gpu_karg' added to kernel arguments."
                        else
                            green_message "'$gpu_karg' is already part of kernel arguments."
                        fi
                        ;;
                esac
                ;;
        esac
    else
        yellow_message "No AMD GPU detected."
    fi

    green_message "LACT is now installed."
}

install_mangohud() {
    declare -A mangohud=(
        [apt]="mangohud"
        [dnf]="mangohud"
        [eopkg]="mangohud"
        [pacman]="mangohud lib32-mangohud"
        [xbps]="MangoHud MangoHud-32bit"
        [zypper]="mangohud mangohud-32bit"
    )

    install_packages() {
        local packages=("$@")
        case "$primary_package_manager" in
            "apt")
                sudo apt-get install -y "${packages[@]}"
                ;;
            "dnf")
                sudo dnf install -y "${packages[@]}"
                ;;
            "eopkg")
                sudo eopkg install -y "${packages[@]}"
                ;;
            "pacman")
                sudo pacman -S --needed --noconfirm "${packages[@]}"
                ;;
            "xbps")
                sudo xbps-install -Sy "${packages[@]}"
                ;;
            "zypper")
                sudo zypper in -y "${packages[@]}"
                ;;
            "rpm-ostree")
                ;;
            *)
                unsupported_package_manager
                return 1
                ;;
        esac
    }

    # Splits string into an array
    read -ra packages <<< "${mangohud[$primary_package_manager]}"
    install_packages "${packages[@]}"

    if [[ "$flatpak_installed" -eq 1 ]]; then
        flatpak install flathub runtime/org.freedesktop.Platform.VulkanLayer.MangoHud
    fi

    mkdir -pv "$HOME/.config/MangoHud"
    mkdir -pv "$HOME/Documents/mangohud/logs"
    cp -v "$HOME/Documents/linux_docs/configs/packages/MangoHud.conf" "$HOME/.config/MangoHud/"

    if [ "$host_system" = "laptop" ]; then

        # Edits FPS limits
        sed -i 's/fps_limit=160,120,90,60,30,0/fps_limit=60,30,0/' "$HOME/.config/MangoHud/MangoHud.conf"

    fi

    echo "output_folder=$HOME/Documents/mangohud/logs" >> "$HOME/.config/MangoHud/MangoHud.conf"

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
    packages=("waydroid")
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
