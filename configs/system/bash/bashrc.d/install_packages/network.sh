# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_install_discord_apt() {
    wget -O "$HOME/Downloads/discord.deb" "https://discord.com/api/download?platform=linux&format=deb"
    sudo apt-get install -y "$HOME/Downloads/discord.deb" && installed=1
    rm -v "$HOME/Downloads/discord.deb"
}

_install_discord_fallback() {
    if [ "$flatpak_installed" -eq 1 ]; then
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        install_flatpak_pkg_bypass com.discordapp.Discord

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
        _install_discord_fallback
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
    install_pm_pkg_bypass "$pkg"
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
        _install_transmission_native && return 0
    fi

    _install_transmission_fallback
}
