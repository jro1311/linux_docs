# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

install_corectrl() {
    detect_system
    local url_prefix="https://download.opensuse.org/repositories/home:Dead_Mozay"

    case "$os" in
        opensuse-tumbleweed)
            sudo zypper addrepo --refresh "$url_prefix"/openSUSE_Tumbleweed/home:Dead_Mozay.repo >/dev/null 2>&1 || return 1
            sudo zypper ref --gpg-auto-import-keys >/dev/null 2>&1 || return 1
            ;;
        opensuse-slowroll)
            sudo zypper addrepo --refresh "$url_prefix"/openSUSE_Slowroll/home:Dead_Mozay.repo >/dev/null 2>&1 || return 1
            sudo zypper ref --gpg-auto-import-keys >/dev/null 2>&1 || return 1
            ;;
    esac

    ensure_pkg "corectrl" || return 1
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
    local installed=0

    case "$primary_pm" in
        dnf) sudo dnf copr enable -y ilyaz/LACT >/dev/null 2>&1 || return 1 ;;
    esac

    case "$primary_pm" in
        rpm-ostree)
            ;;
        *)
            if ensure_pkg "lact"; then
                installed=1
            fi
            ;;
    esac

    if [ "$installed" -eq 0 ]; then
        _install_lact_fallback || return 1
    fi
}

install_mangohud() {
    detect_system

    case "$primary_pm" in
        rpm-ostree) ;;
        *) ensure_pkg "mangohud" ;;
    esac

    case "$primary_pm" in
        pacman) ensure_pkg "lib32-mangohud" ;;
        xbps)   ensure_pkg "MangoHud-32bit" ;;
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
            wget -O "$dir_prefix/Minecraft.deb" "$url_prefix/Minecraft.deb" || return 1
            install_pm_pkg_bypass "$dir_prefix/Minecraft.deb" || return 1
            rm -f "$dir_prefix/Minecraft.deb"
            ;;
        pacman)
            install_aur_pkg_bypass "minecraft-launcher" || return 1
            ;;
        *)
            wget -O "$dir_prefix/Minecraft.tar.gz" "$url_prefix/Minecraft.tar.gz" || return 1
            tar -xf "$dir_prefix/Minecraft.tar.gz" -C "$dir_prefix/" || return 1
            rm -f "$dir_prefix/Minecraft.tar.gz"
            ;;
    esac
}

install_proton_ge() {
    local path_prefix
    path_prefix=$(define_steam_prefix) || return 1

    rm -rf /tmp/proton-ge-custom || return 1
    mkdir /tmp/proton-ge-custom || return 1
    cd /tmp/proton-ge-custom || return 1

    tarball_url=$(
        curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest \
        | grep browser_download_url \
        | cut -d\" -f4 \
        | grep .tar.gz
    )
    tarball_name=$(basename "$tarball_url")
    curl -# -L "$tarball_url" -o "$tarball_name" || return 1

    checksum_url=$(
        curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest \
        | grep browser_download_url \
        | cut -d\" -f4 \
        | grep .sha512sum
    )
    checksum_name=$(basename "$checksum_url")
    curl -# -L "$checksum_url" -o "$checksum_name" || return 1

    sha512sum -c "$checksum_name" || return 1

    mkdir -p "$path_prefix/compatibilitytools.d/" || return 1
    tar -xf "$tarball_name" -C "$path_prefix/compatibilitytools.d/" || return 1
}
