# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

install_cursor_bibata() {
    detect_system
    local pkg="${bibata_cursor_pkg[$primary_pm]}"
    local installed=0

    case "$os" in
        fedora) sudo dnf config-manager --add-repo https://terra.fyralabs.com/terra.repo ;;
    esac

    if [ -n "$pkg" ]; then
        install_pm_pkg_bypass "$pkg" && installed=1
    fi

    if [ "$installed" -eq 0 ]; then
        manual_install_required "Bibata Cursor"
        yellow_message "Download:" "https://github.com/ful1e5/Bibata_Cursor"
        return 0
    fi
}

install_cursor_dmz() {
    detect_system
    local pkg="${dmz_cursor_pkg[$primary_pm]}"
    local installed=0

    if [ -n "$pkg" ]; then
        install_pm_pkg_bypass "$pkg" && installed=1
    fi

    if [ "$installed" -eq 0 ]; then
        manual_install_required "DMZ Cursor"
        yellow_message "Download:" "https://github.com/rhizoome/dmz-cursors"
        return 0
    fi
}

install_icons_elementary() {
    detect_system
    local pkg="${elementary_icons_pkg[$primary_pm]}"
    local installed=0

    if [ -n "$pkg" ]; then
        install_pm_pkg_bypass "$pkg" && installed=1
    fi

    if [ "$installed" -eq 0 ]; then
        manual_install_required "Elementary icons"
        yellow_message "Download:" "https://github.com/shimmerproject/elementary-xfce"
        return 0
    fi
}

install_theme_greybird() {
    detect_system
    local -a packages
    local read -ra packages <<< "${greybird_theme_pkg[$primary_pm]}"
    local installed=0

    case "$os" in
        openmandriva) ;;
        *)
            install_pm_pkg_bypass "${packages[@]}" && installed=1
            ;;
    esac

    if [ "$installed" -eq 0 ]; then
        manual_install_required "Greybird theme"
        yellow_message "Download:" "https://github.com/shimmerproject/Greybird"
        return 0
    fi
}

install_fonts_ubuntu() {
    detect_system
    local -a packages
    read -ra packages <<< "${ubuntu_fonts_pkg[$primary_pm]}"
    local installed=0

    install_pm_pkg_bypass "${packages[@]}" && installed=1

    if [ "$installed" -eq 0 ] ;then
        manual_install_required "Ubuntu fonts"
        yellow_message "Download:" "https://design.ubuntu.com/font"
        return 0
    fi
}

_install_fonts_microsoft_apt() {
    detect_system
    case "$os" in
        ubuntu)
            sudo apt-get install -y software-properties-common
            sudo add-apt-repository multiverse
            ;;
        debian)
            enable_debian_contrib
            ;;
        *)
            case " $os_like " in
                *" ubuntu "*)
                    sudo apt-get install -y software-properties-common
                    sudo add-apt-repository multiverse
                    ;;
                *" debian "*)
                    enable_debian_contrib
                    ;;
                *)
                    unsupported_operating_system
                    return 1
                    ;;
            esac
            ;;
    esac

    sudo apt-get install -y ttf-mscorefonts-installer
}

_install_fonts_microsoft_dnf() {
    case "$os" in
        openmandriva)
            return 1
            ;;
        *)
            sudo dnf install -y cabextract curl xorg-x11-font-utils
            sudo dnf install -y https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
            ;;
    esac
}

_install_fonts_microsoft_eopkg() {
    sudo eopkg install -y fonts-installer
}

_install_fonts_microsoft_pacman() {
    install_aur_pkg_bypass "ttf-ms-win11-auto"
}

_install_fonts_microsoft_rpm_ostree() {
    if [ -f /run/.containerenv ]; then
        red_message "Error:" "Do not run this inside a toolbox."
        return 1
    fi

    local script_dir
    local install_dir

    script_dir="$(cd "$(dirname "$0")" && pwd)"
    install_dir="$script_dir/mscorefonts_tmp"
    mkdir -p "$install_dir"

    cat << 'EOF' > "$install_dir/mscorefonts-part2.sh"
#!/bin/bash
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
for i in "${fonts[@]}"; do
    wget "$i" &>/dev/null
    cabextract "$(basename "$i")" -d fonts &>/dev/null
done
mkdir -p "$HOME/.local/share/fonts/mscorefonts"
cp fonts/*.ttf fonts/*.TTF "$HOME/.local/share/fonts/mscorefonts/" 2>/dev/null
EOF

    cat << 'EOF' > "$install_dir/mscorefonts-part3.sh"
#!/bin/bash
script_dir="$1"
install_dir="$2"
sudo mkdir -p /usr/local/share/fonts/mscorefonts/
sudo cp "$HOME/.local/share/fonts/mscorefonts/"*.ttf "$HOME/.local/share/fonts/mscorefonts/"*.TTF /usr/local/share/fonts/mscorefonts/ 2>/dev/null
fc-cache -f >/dev/null
toolbox rm -f solidcore-tmp
cd "$script_dir"
rm -rf cabextract-1.11.tar.gz cabextract-1.11 "$install_dir"
EOF

    chmod +x "$install_dir/mscorefonts-part2.sh" "$install_dir/mscorefonts-part3.sh"
    trap 'bash $install_dir/mscorefonts-part3.sh "$script_dir" "$install_dir"' EXIT

    if toolbox create -y solidcore-tmp &>/dev/null; then
        if ! toolbox run -c solidcore-tmp bash "$install_dir/mscorefonts-part2.sh"; then
            red_message "Error:" "Failed to run script in toolbox."
            return 1
        fi
    else
        red_message "Error: Failed to create toolbox."
        return 1
    fi
}

_install_fonts_microsoft_xbps() {
    sudo xbps-install -Sy git xtools

    git clone https://github.com/void-linux/void-packages "$HOME/Downloads"
    cd "$HOME/Downloads/void-packages" || return 1

    ./xbps-src binary-bootstrap
    echo "XBPS_ALLOW_RESTRICTED=yes" >> etc/conf

    ./xbps-src pkg -f msttcorefonts
    xi msttcorefonts
}

_install_fonts_microsoft_zypper() {
    sudo zypper in -y fetchmsttfonts
}

install_fonts_microsoft() {
    detect_system
    local installed=0

    install_pm_pkg_bypass "fontconfig"

    case "$primary_pm" in
        apt)        _install_fonts_microsoft_apt && installed=1 ;;
        dnf)        _install_fonts_microsoft_dnf && installed=1 ;;
        eopkg)      _install_fonts_microsoft_eopkg && installed=1 ;;
        pacman)     _install_fonts_microsoft_pacman && installed=1 ;;
        xbps)       _install_fonts_microsoft_xbps && installed=1 ;;
        zypper)     _install_fonts_microsoft_zypper && installed=1 ;;
        rpm-ostree) _install_fonts_microsoft_rpm_ostree && installed=1 ;;
    esac

    if [ "$installed" -eq 0 ]; then
        manual_install_required "Microsoft fonts"
        return 0
    fi
}
