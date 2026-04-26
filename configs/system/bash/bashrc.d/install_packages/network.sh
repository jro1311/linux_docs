# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_install_discord_apt() {
    wget -O "$HOME/Downloads/discord.deb" "https://discord.com/api/download?platform=linux&format=deb" || return 1
    sudo apt-get install -y "$HOME/Downloads/discord.deb" || return 1
    rm "$HOME/Downloads/discord.deb" || return 1
}

_install_discord_fallback() {
    if [ "$flatpak_installed" -eq 1 ]; then
        install_flatpak_pkg_bypass "com.discordapp.Discord"

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
            install_pm_pkg_bypass "discord" && installed=1
            ;;
    esac

    if [ "$installed" -eq 0 ]; then
        _install_discord_fallback || return 1
    fi
}

_select_transmission_pkg() {
    if is_qt_desktop "$desktop" || is_window_manager "$desktop"; then
        printf '%s\n' "${transmission_qt_pkg[$primary_pm]}"
    else
        printf '%s\n' "${transmission_gtk_pkg[$primary_pm]}"
    fi
}

_install_transmission_native() {
    local pkg

    pkg=$(_select_transmission_pkg)
    install_pm_pkg_bypass "$pkg" || return 1
}

_install_transmission_fallback() {
    if [ "$flatpak_installed" -eq 1 ]; then
        install_flatpak_pkg_bypass "com.transmissionbt.Transmission"

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
