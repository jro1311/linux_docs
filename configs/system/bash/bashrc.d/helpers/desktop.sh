# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

window_managers=(
    awesome
    enlightenment
    fluxbox
    hyprland
    i3
    openbox
    qtile
    sway
    xmonad
)

qt_desktops=(
    lxqt
    kde
    plasma
)

gtk_desktops=(
    budgie
    cosmic
    deepin
    gnome
    lxde
    mate
    pantheon
    ubuntu
    unity
    x-cinnamon
    xfce
)

all_desktops=(
    "${qt_desktops[@]}"
    "${gtk_desktops[@]}"
)

is_window_manager() {
    local desktop=$1
    in_array "$desktop" "${window_managers[@]}" && return 0
    case $desktop in
        *wm) return 0 ;;
    esac
    return 1
}

is_qt_desktop() {
    local desktop=$1
    in_array "$desktop" "${qt_desktops[@]}" && return 0
    return 1
}

is_gtk_desktop() {
    local desktop=$1
    in_array "$desktop" "${gtk_desktops[@]}" && return 0
    return 1
}

install_desktop_packages() {
    case "$desktop" in
        awesome|enlightenment|fluxbox|hyprland|i3|openbox|qtile|sway|xmonad|*wm)
            install_pm_pkg_bypass "${qt_packages[@]}"
            ;;
        budgie|cosmic|deepin|pantheon|x-cinnamon)
            install_pm_pkg_bypass "${gtk_packages[@]}"
            ;;
        gnome|ubuntu)
            install_pm_pkg_bypass \
                "${gtk_packages[@]}" \
                "${gnome_packages[@]}"
            ;;
        lxde|mate|unity)
            install_pm_pkg_bypass "${gtk_packages[@]}"
            ;;
        lxqt)
            install_pm_pkg_bypass "${qt_packages[@]}"
            ;;
        kde|plasma)
            install_pm_pkg_bypass "${qt_packages[@]}"
            ;;
        xfce)
            install_pm_pkg_bypass \
                "${gtk_packages[@]}" \
                "${xfce_packages[@]}"
            ;;
        *)
            unsupported_desktop
            return 1
            ;;
    esac
}

install_gnome_distro_packages() {
    case "$os" in
        debian)
            if [ "$VERSION_ID" -ge 13 ]; then
                sudo apt-get install -y "${debian_gnome_packages[@]}"
            fi
            ;;
        ubuntu)
            if echo "$VERSION_ID >= 25.10" | bc -l | grep -Fq "1"; then
                sudo apt-get install -y "${debian_gnome_packages[@]}"
            fi
            ;;
        *)
            case " $os_like " in
                " debian ")
                    if [ "$VERSION_ID" -ge 13 ]; then
                        sudo apt-get install -y "${debian_gnome_packages[@]}"
                    fi
                    ;;
                *" ubuntu "*)
                    if echo "$VERSION_ID >= 25.10" | bc -l | grep -Fq "1"; then
                        sudo apt-get install -y "${debian_gnome_packages[@]}"
                    else
                        sudo apt-get install -y chrome-gnome-shell gnome-shell-extension-manager
                    fi
                    ;;
            esac
            ;;
    esac
}

install_desktop_flatpaks() {
    case "$desktop" in
        kde|plasma)
            ;;
        gnome|ubuntu)
            flatpak install flathub -y \
                com.github.tchx84.Flatseal \
                com.mattjakeman.ExtensionManager
            ;;
        *)
            flatpak install flathub -y com.github.tchx84.Flatseal
            ;;
    esac
}

disable_baloo() {
    local bin
    for bin in balooctl6 balooctl; do
        if command -v "$bin" >/dev/null 2>&1; then
            "$bin" disable
            green_message "Disabled:" "baloo"
            return 0
        fi
    done
}

apply_desktop_adjustments() {
    case "$desktop" in
        kde|plasma)
            disable_baloo
            ;;
    esac
}

setup_desktop() {
    install_desktop_packages

    if [ "$desktop" = "gnome" ] || [ "$desktop" = "ubuntu" ]; then
        install_gnome_distro_packages
    fi

    install_desktop_flatpaks
    apply_desktop_adjustments
}
