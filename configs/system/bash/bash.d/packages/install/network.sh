# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_install_discord_apt() {
    wget -O "$HOME/Downloads/discord.deb" "https://discord.com/api/download?platform=linux&format=deb" || return 1
    install_pm_pkg_bypass "$HOME/Downloads/discord.deb" || return 1
    rm -f "$HOME/Downloads/discord.deb"
}

_install_discord_fallback() {
    local flatpak="com.discordapp.Discord"

    if [ "$flatpak_installed" -eq 1 ] && ! pkg_installed_flatpak "$flatpak"; then
        install_flatpak_pkg_bypass "$flatpak"

    elif [ "$snap_installed" -eq 1 ]; then
        sudo snap install discord

    else
        unsupported_package_manager
        return 1
    fi
}

install_discord() {
    detect_system
    local installed=0

    case "$primary_pm" in
        apt)
            _install_discord_apt
            ;;
        dnf|eopkg|pacman|zypper)
            ensure_pkg "discord" && installed=1
            ;;
    esac

    if [ "$installed" -eq 0 ]; then
        _install_discord_fallback || return 1
    fi
}

_install_transmission_native() {
    local pkg

    if is_qt_preferred_env "$desktop"; then
        pkg="${transmission_qt_pkg[$primary_pm]}"
    else
        pkg="${transmission_gtk_pkg[$primary_pm]}"
    fi

    ensure_pkg "$pkg" || return 1
}

_install_transmission_fallback() {
    local flatpak="com.transmissionbt.Transmission"

    if [ "$flatpak_installed" -eq 1 ] && ! pkg_installed_flatpak "$flatpak"; then
        install_flatpak_pkg_bypass "$flatpak"

    elif [ "$snap_installed" -eq 1 ]; then
        sudo snap install transmission
    else
        unsupported_package_manager
        return 1
    fi
}

install_transmission() {
    detect_system

    if [ "$primary_pm" != "rpm-ostree" ]; then
        _install_transmission_native || return 1
        return 0
    fi

    _install_transmission_fallback || return 1
}
