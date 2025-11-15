install_fonts_microsoft_apt() {
    sudo apt-get install -y software-properties-common

    case "$os" in
        "debian")
            sudo apt-add-repository -y contrib non-free-firmware
            ;;
        "ubuntu")
            sudo add-apt-repository multiverse
            ;;
        *)
            case "$os_like" in
                "debian")
                    sudo apt-add-repository -y contrib non-free-firmware
                    ;;
                "ubuntu debian"|"ubuntu")
                    sudo add-apt-repository multiverse
                    ;;
                *)
                    echo "${red}Unsupported distribution. ${reset}"
                    return 1
                    ;;
            esac
            ;;
    esac

    sudo apt-get install -y fontconfig ttf-mscorefonts-installer
}

install_fonts_microsoft_dnf() {
    case "$os" in
        "openmandriva")
            yellow_message "Manual installation required."
            return 0
            ;;
        *)
            sudo dnf install -y cabextract curl fontconfig xorg-x11-font-utils
            sudo dnf install -y https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
            ;;
    esac
}

install_fonts_microsoft_eopkg() { sudo eopkg install -y fonts-installer fontconfig; }

install_fonts_microsoft_pacman() {
    case "$secondary_package_manager" in
        "paru"|"yay")
            "$secondary_package_manager" -S --needed --noconfirm ttf-ms-win11-auto
            ;;
        *)
            install_paru
            paru -S --needed --noconfirm ttf-ms-win11-auto
            ;;
    esac
}

install_fonts_microsoft_xbps() { sudo xbps-install -Sy greybird-themes; }

install_fonts_microsoft_zypper() { sudo zypper in -y fetchmsttfonts fontconfig; }

install_fonts_microsoft_rpm_ostree() {
    if [ -f /run/.containerenv ]; then
        echo "This script should not be run inside a toolbox. Exiting."
        return 1
    fi

    # Define script dir as the current directory
    script_dir="$(cd "$(dirname "$0")" && pwd)"

    # Create install dir
    install_dir="$script_dir/mscorefonts_tmp"
    mkdir -p "$install_dir"

    # Create mscorefonts-part2.sh
    cat << 'EOF' > "$install_dir/mscorefonts-part2.sh"
    #!/bin/bash

    # Part 2

    # Install Make and GCC
    echo "Installing required packages. This will may a while..."
    sudo dnf -y install make gcc &>/dev/null

    # Download and compile cabextract
    wget --timeout=60 --max-redirect=20 https://www.cabextract.org.uk/cabextract-1.11.tar.gz &>/dev/null
    tar -zxf cabextract-1.11.tar.gz &>/dev/null
    cd cabextract-1.11
    ./configure --prefix=/usr/local &>/dev/null && make &>/dev/null
    sudo make install &>/dev/null

    # Download and extract fonts
    _sfpath="http://downloads.sourceforge.net/corefonts"
    fonts=(
        $_sfpath/andale32.exe
        $_sfpath/arial32.exe
        $_sfpath/arialb32.exe
        $_sfpath/comic32.exe
        $_sfpath/courie32.exe
        $_sfpath/georgi32.exe
        $_sfpath/impact32.exe
        $_sfpath/times32.exe
        $_sfpath/trebuc32.exe
        $_sfpath/verdan32.exe
        $_sfpath/webdin32.exe
        )

    mkdir fonts 2>/dev/null

    echo "Downloading and extracting fonts..."

    for i in "${fonts[@]}"
    do
        wget $i &>/dev/null
        cabextract $(basename $i) -d fonts &>/dev/null
    done

    # Install for user
    echo "Installing fonts for user..."
    mkdir "$HOME/.local/share/fonts" 2>/dev/null
    mkdir "$HOME/.local/share/fonts/mscorefonts" 2>/dev/null
    cp fonts/*.ttf fonts/*.TTF $HOME/.local/share/fonts/mscorefonts/ 2>/dev/null
EOF

    # Create mscorefonts-part3.sh
    cat << 'EOF' > "$install_dir/mscorefonts-part3.sh"

    #!/bin/bash

    # Part 3

    # Grab variables
    script_dir="$1"
    install_dir="$2"

    # Install system-wide
    echo "Installing fonts system-wide (requires sudo)..."
    sudo mkdir /usr/local/share/fonts/ 2>/dev/null
    sudo mkdir /usr/local/share/fonts/mscorefonts/ 2>/dev/null
    sudo cp "$HOME/.local/share/fonts/mscorefonts/"*.ttf "$HOME/.local/share/fonts/mscorefonts/"*.TTF /usr/local/share/fonts/mscorefonts/ 2>/dev/null

    # Refresh font cache
    echo "Refreshing font cache..."
    fc-cache -f >/dev/null

    # Cleanup
    echo "Cleaning up..."
    toolbox rm -f solidcore-tmp
    cd "$script_dir"
    rm -rf cabextract-1.11.tar.gz cabextract-1.11
    rm -rf "$install_dir"
    echo "All done."
EOF

    chmod +x "$install_dir/mscorefonts-part2.sh"
    chmod +x "$install_dir/mscorefonts-part3.sh"

    # Create a trap to run part 3 and passing along the needed variables after toolbox exit
    trap 'bash $install_dir/mscorefonts-part3.sh \"$script_dir\" \"$install_dir\"' EXIT

    # Create temporary toolbox and run part 2 in it
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
        "apt")          install_fonts_microsoft_apt ;;
        "dnf")          install_fonts_microsoft_dnf ;;
        "eopkg")        install_fonts_microsoft_eopkg ;;
        "pacman")       install_fonts_microsoft_pacman ;;
        "xbps")         install_fonts_microsoft_xbps ;;
        "zypper")       install_fonts_microsoft_zypper ;;
        "rpm-ostree")   install_fonts_microsoft_rpm_ostree ;;
        *)
            yellow_message "Manual installation required."
            return 0
            ;;
    esac

    mkdir -pv "$HOME/.config/fontconfig"
    cp -v "$HOME/Documents/linux_docs/configs/packages/fontconfig/fonts.conf" "$HOME/.config/fontconfig/"

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
            yellow_message "Manual installation required. Download: https://github.com/shimmerproject/elementary-xfce"
            return 0
            ;;
    esac

    green_message "Ubuntu fonts are now installed."
}
