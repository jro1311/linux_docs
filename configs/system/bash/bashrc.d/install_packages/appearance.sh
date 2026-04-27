# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

install_cursor_bibata() {
    detect_system
    local pkg="${bibata_cursor_pkg[$primary_pm]}"
    local installed=0

    case "$os" in
        fedora) sudo dnf config-manager --add-repo https://terra.fyralabs.com/terra.repo || return 1 ;;
    esac

    if [ -n "$pkg" ]; then
        install_pm_pkg_bypass "$pkg" && installed=1
    fi

    if [ "$installed" -eq 0 ]; then
        manual_install_required "Bibata Cursor" "https://github.com/ful1e5/Bibata_Cursor"
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
        manual_install_required "DMZ Cursor" "https://github.com/rhizoome/dmz-cursors"
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
        manual_install_required "Elementary icons" "https://github.com/shimmerproject/elementary-xfce"
        return 0
    fi
}

install_theme_greybird() {
    detect_system
    local -a pkgs
    local read -ra pkgs <<< "${greybird_theme_pkg[$primary_pm]}"
    local installed=0

    case "$os" in
        openmandriva) ;;
        *) install_pm_pkg_bypass "${pkgs[@]}" && installed=1 ;;
    esac

    if [ "$installed" -eq 0 ]; then
        manual_install_required "Greybird theme" "https://github.com/shimmerproject/Greybird"
        return 0
    fi
}

install_fonts_ubuntu() {
    detect_system
    local -a pkgs
    read -ra pkgs <<< "${ubuntu_fonts_pkg[$primary_pm]}"
    local installed=0

    install_pm_pkg_bypass "${pkgs[@]}" && installed=1

    if [ "$installed" -eq 0 ] ;then
        manual_install_required "Ubuntu fonts" "https://design.ubuntu.com/font"
        return 0
    fi
}

_install_fonts_microsoft_apt() {
    detect_system
    case "$os" in
        ubuntu)
            sudo apt-get install -y software-properties-common || return 1
            sudo add-apt-repository multiverse || return 1
            ;;
        debian)
            enable_debian_contrib || return 1
            ;;
        *)
            case " $os_like " in
                *" ubuntu "*)
                    sudo apt-get install -y software-properties-common || return 1
                    sudo add-apt-repository multiverse || return 1
                    ;;
                *" debian "*)
                    enable_debian_contrib || return 1
                    ;;
                *)
                    unsupported_operating_system
                    return 1
                    ;;
            esac
            ;;
    esac

    sudo apt-get install -y ttf-mscorefonts-installer || return 1
}

_install_fonts_microsoft_dnf() {
    case "$os" in
        openmandriva) return 1 ;;
        *)
            sudo dnf install -y cabextract curl xorg-x11-font-utils || return 1
            sudo dnf install -y https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm || return 1
            ;;
    esac
}

_install_fonts_microsoft_eopkg() {
    sudo eopkg install -y fonts-installer || return 1
}

_install_fonts_microsoft_pacman() {
    install_aur_pkg_bypass "ttf-ms-win11-auto" || return 1
}

_rpm_ostree_fonts_validate_env() {
    if [ -f /run/.containerenv ]; then
        red_message "Error:" "Do not run this inside a toolbox."
        return 1
    fi
}

_rpm_ostree_fonts_prepare_tmpdir() {
    script_dir="$(cd "$(dirname "$0")" && pwd)" || return 1
    install_dir="$script_dir/mscorefonts_tmp"

    mkdir -p "$install_dir" || return 1
}

_rpm_ostree_fonts_generate_scripts() {
    cat << 'EOF' > "$install_dir/mscorefonts-part2.sh" || return 1
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

    cat << 'EOF' > "$install_dir/mscorefonts-part3.sh" || return 1
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

    chmod +x "$install_dir/mscorefonts-part2.sh" "$install_dir/mscorefonts-part3.sh" || return 1
}

_rpm_ostree_fonts_run_toolbox() {
    trap 'bash $install_dir/mscorefonts-part3.sh "$script_dir" "$install_dir"' EXIT

    toolbox create -y solidcore-tmp &>/dev/null || {
        red_message "Error:" "Failed to create toolbox."
        return 1
    }

    toolbox run -c solidcore-tmp bash "$install_dir/mscorefonts-part2.sh" || {
        red_message "Error:" "Failed to run script in toolbox."
        return 1
    }
}

_install_fonts_microsoft_rpm_ostree() {
    _rpm_ostree_fonts_validate_env || return 1
    _rpm_ostree_fonts_prepare_tmpdir || return 1
    _rpm_ostree_fonts_generate_scripts || return 1
    _rpm_ostree_fonts_run_toolbox || return 1
}

_install_fonts_microsoft_xbps() {
    sudo xbps-install -Sy git xtools || return 1

    git clone https://github.com/void-linux/void-packages "$HOME/Downloads" || return 1
    cd "$HOME/Downloads/void-packages" || return 1

    ./xbps-src binary-bootstrap || return 1
    echo "XBPS_ALLOW_RESTRICTED=yes" | sudo tee -a etc/conf >/dev/null 2>&1 || return 1

    ./xbps-src pkg -f msttcorefonts || return 1
    xi msttcorefonts || return 1
}

_install_fonts_microsoft_zypper() {
    sudo zypper in -y fetchmsttfonts || return 1
}

install_fonts_microsoft() {
    detect_system
    local installed=0

    install_pm_pkg_bypass "fontconfig" || return 1

    case "$primary_pm" in
        apt)        _install_fonts_microsoft_apt || return 1; installed=1 ;;
        dnf)        _install_fonts_microsoft_dnf || return 1; installed=1 ;;
        eopkg)      _install_fonts_microsoft_eopkg || return 1; installed=1 ;;
        pacman)     _install_fonts_microsoft_pacman || return 1; installed=1 ;;
        xbps)       _install_fonts_microsoft_xbps || return 1; installed=1 ;;
        zypper)     _install_fonts_microsoft_zypper || return 1; installed=1 ;;
        rpm-ostree) _install_fonts_microsoft_rpm_ostree || return 1; installed=1 ;;
    esac

    if [ "$installed" -eq 0 ]; then
        manual_install_required "Microsoft fonts"
        return 0
    fi
}
