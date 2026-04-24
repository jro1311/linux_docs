# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

install_corectrl() {
    detect_system
    case "$os" in
        opensuse-tumbleweed)
            sudo zypper addrepo https://download.opensuse.org/repositories/home:Dead_Mozay/openSUSE_Tumbleweed/home:Dead_Mozay.repo \
                && sudo zypper ref
            ;;
        opensuse-slowroll)
            sudo zypper addrepo https://download.opensuse.org/repositories/home:Dead_Mozay/openSUSE_Slowroll/home:Dead_Mozay.repo \
                && sudo zypper ref
            ;;
    esac

    install_pm_pkg_bypass "corectrl" || return 1
}

_install_lact_fallback() {
    if [ "$flatpak_installed" -eq 1 ]; then
        install_flatpak_pkg_bypass "io.github.ilya_zlobintsev.LACT"
    else
        unsupported_package_manager
        return 1
    fi
}

install_lact() {
    detect_system
    local pkg="${lact_pkg[$primary_pm]}"
    local installed=0

    case "$primary_pm" in
        dnf) sudo dnf copr enable -y ilyaz/LACT ;;
    esac

    case "$primary_pm" in
        rpm-ostree)
            ;;
        *)
            if [ -n "$pkg" ]; then
                install_pm_pkg_bypass "$pkg" && installed=1
            fi
            ;;
    esac

    if [ "$installed" -eq 0 ]; then
        _install_lact_fallback
    fi
}

install_mangohud() {
    detect_system
    local -a packages
    read -ra packages <<< "${mangohud_pkg[$primary_pm]}"

    case "$primary_pm" in
        rpm-ostree) ;;
        *) install_pm_pkg_bypass "${packages[@]}" ;;
    esac

    if [ "$flatpak_installed" -eq 1 ]; then
        install_flatpak_pkg_bypass "org.freedesktop.Platform.VulkanLayer.MangoHud"
    fi
}

install_minecraft() {
    detect_system
    local dir_prefix url_prefix
    url_prefix="https://launcher.mojang.com/download"
    dir_prefix="$HOME/Downloads"

    case "$primary_pm" in
        apt)
            wget -O "$dir_prefix/Minecraft.deb" "$url_prefix/Minecraft.deb"
            sudo apt-get install -y "$dir_prefix/Minecraft.deb"
            rm -v "$dir_prefix/Minecraft.deb"
            ;;
        pacman)
            install_aur_pkg_bypass "minecraft-launcher"
            ;;
        *)
            wget -O "$dir_prefix/Minecraft.tar.gz" "$url_prefix/Minecraft.tar.gz"
            tar -xvf "$dir_prefix/Minecraft.tar.gz" -C "$dir_prefix/"
            rm -v "$dir_prefix/Minecraft.tar.gz"
            ;;
    esac
}

install_proton_ge() {
    local path_prefix
    path_prefix=$(define_steam_prefix)

    rm -rf /tmp/proton-ge-custom
    mkdir /tmp/proton-ge-custom
    cd /tmp/proton-ge-custom || return 1

    tarball_url=$(
        curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest \
        | grep browser_download_url \
        | cut -d\" -f4 \
        | grep .tar.gz
    )
    tarball_name=$(basename "$tarball_url")
    curl -# -L "$tarball_url" -o "$tarball_name"

    checksum_url=$(
        curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest \
        | grep browser_download_url \
        | cut -d\" -f4 \
        | grep .sha512sum
    )
    checksum_name=$(basename "$checksum_url")
    curl -# -L "$checksum_url" -o "$checksum_name"

    sha512sum -c "$checksum_name"

    mkdir -pv "$path_prefix/compatibilitytools.d/"
    tar -xfv "$tarball_name" -C "$path_prefix/compatibilitytools.d/"
}
