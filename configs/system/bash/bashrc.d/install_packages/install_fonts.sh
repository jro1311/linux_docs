install_fonts_microsoft_rpm_ostree() {
    if [ -f /run/.containerenv ]; then
        echo "This script should not be run inside a toolbox. Exiting."
        return 1
    fi

    script_dir="$(cd "$(dirname "$0")" && pwd)"
    install_dir="$script_dir/mscorefonts_tmp"
    mkdir -p "$install_dir"

    # Create mscorefonts-part2.sh
    cat << 'EOF' > "$install_dir/mscorefonts-part2.sh"
    #!/bin/bash
    echo "Installing required packages. This may take a while..."
    sudo dnf -y install make gcc &>/dev/null
    wget --timeout=60 --max-redirect=20 https://www.cabextract.org.uk/cabextract-1.11.tar.gz &>/dev/null
    tar -zxf cabextract-1.11.tar.gz &>/dev/null
    cd cabextract-1.11
    ./configure --prefix=/usr/local &>/dev/null && make &>/dev/null
    sudo make install &>/dev/null
    _sfpath="http://downloads.sourceforge.net/corefonts"
    fonts=( $_sfpath/andale32.exe $_sfpath/arial32.exe $_sfpath/arialb32.exe $_sfpath/comic32.exe
            $_sfpath/courie32.exe $_sfpath/georgi32.exe $_sfpath/impact32.exe $_sfpath/times32.exe
            $_sfpath/trebuc32.exe $_sfpath/verdan32.exe $_sfpath/webdin32.exe )
    mkdir fonts 2>/dev/null
    echo "Downloading and extracting fonts..."
    for i in "${fonts[@]}"; do
        wget "$i" &>/dev/null
        cabextract "$(basename "$i")" -d fonts &>/dev/null
    done
    echo "Installing fonts for user..."
    mkdir -p "$HOME/.local/share/fonts/mscorefonts"
    cp fonts/*.ttf fonts/*.TTF "$HOME/.local/share/fonts/mscorefonts/" 2>/dev/null
EOF

    # Create mscorefonts-part3.sh
    cat << 'EOF' > "$install_dir/mscorefonts-part3.sh"
    #!/bin/bash
    script_dir="$1"
    install_dir="$2"
    echo "Installing fonts system-wide (requires sudo)..."
    sudo mkdir -p /usr/local/share/fonts/mscorefonts/
    sudo cp "$HOME/.local/share/fonts/mscorefonts/"*.ttf "$HOME/.local/share/fonts/mscorefonts/"*.TTF /usr/local/share/fonts/mscorefonts/ 2>/dev/null
    echo "Refreshing font cache..."
    fc-cache -f >/dev/null
    echo "Cleaning up..."
    toolbox rm -f solidcore-tmp
    cd "$script_dir"
    rm -rf cabextract-1.11.tar.gz cabextract-1.11 "$install_dir"
    echo "All done."
EOF

    chmod +x "$install_dir/mscorefonts-part2.sh" "$install_dir/mscorefonts-part3.sh"
    trap 'bash $install_dir/mscorefonts-part3.sh "$script_dir" "$install_dir"' EXIT

    echo "Creating temporary toolbox..."
    if toolbox create -y solidcore-tmp &>/dev/null; then
        if ! toolbox run -c solidcore-tmp bash "$install_dir/mscorefonts-part2.sh"; then
            red_message "Error: Failed to run script in toolbox."
            return 1
        fi
    else
        red_message "Error: Failed to create toolbox."
        return 1
    fi

    inverse_check fontconfig \
        sudo rpm-ostree install fontconfig
}

install_fonts_microsoft() {
    case "$primary_package_manager" in
        "apt")
            case "$os" in
                "debian")
                    enable_debian_contrib
                    ;;
                "ubuntu")
                    sudo apt-get install -y software-properties-common
                    sudo add-apt-repository multiverse
                    ;;
                *)
                    case "$os_like" in
                        "debian")
                            enable_debian_contrib
                            ;;
                        "ubuntu debian"|"ubuntu")
                            sudo apt-get install -y software-properties-common
                            sudo add-apt-repository multiverse
                            ;;
                        *)
                            unsupported_operating_system
                            return 1
                            ;;
                    esac
                    ;;
            esac
            sudo apt-get install -y fontconfig ttf-mscorefonts-installer
            ;;
        "dnf")
            case "$os" in
                "openmandriva")
                    yellow_message "Manual installation required for Microsoft fonts."
                    return 0
                    ;;
                *)
                    sudo dnf install -y cabextract curl fontconfig xorg-x11-font-utils
                    sudo dnf install -y https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm ;;
            esac
            ;;
        "eopkg")
            sudo eopkg install -y fonts-installer fontconfig
            ;;
        "pacman")
            case "$secondary_package_manager" in
                "paru"|"yay")
                    "$secondary_package_manager" -S --needed --noconfirm ttf-ms-win11-auto
                    ;;
                *)
                    install_yay
                    yay -S --needed --noconfirm ttf-ms-win11-auto
                    ;;
            esac
            ;;
        "xbps")
            sudo xbps-install -Sy greybird-themes
            ;;
        zypper)
            sudo zypper in -y fetchmsttfonts fontconfig
            ;;
        rpm-ostree)
            install_fonts_microsoft_rpm_ostree
            ;;
        *)
            yellow_message "Manual installation required for Microsoft fonts."
            return 0
            ;;
    esac

    mkdir -pv "$HOME/.config/fontconfig"
    cp -v "$HOME/Documents/linux_docs/configs/system/fontconfig/fonts.conf" "$HOME/.config/fontconfig/"

    green_message "Microsoft fonts are now installed."
}

install_fonts_ubuntu() {
    case "$primary_package_manager" in
        "eopkg")
            sudo eopkg install -y font-ubuntu-sans-ttf font-ubuntu-ttf
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm ttf-ubuntu-font-family
            ;;
        "zypper")
            sudo zypper in -y ubuntu-fonts
            ;;
        *)
            yellow_message "Manual installation required."
            yellow_message "Download:" "https://github.com/shimmerproject/elementary-xfce"
            return 0
            ;;
    esac

    green_message "Ubuntu fonts are now installed."
}
