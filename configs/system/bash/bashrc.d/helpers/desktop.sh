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

install_desktop_pkgs() {
    case "$desktop" in
        awesome|enlightenment|fluxbox|hyprland|i3|openbox|qtile|sway|xmonad|*wm)
            install_pm_pkg_bypass "${qt_pkgs[@]}"
            ;;
        budgie|cosmic|deepin|pantheon|x-cinnamon)
            install_pm_pkg_bypass "${gtk_pkgs[@]}"
            ;;
        gnome|ubuntu)
            install_pm_pkg_bypass \
                "${gtk_pkgs[@]}" \
                "${gnome_pkgs[@]}"
            ;;
        lxde|mate|unity)
            install_pm_pkg_bypass "${gtk_pkgs[@]}"
            ;;
        lxqt)
            install_pm_pkg_bypass "${qt_pkgs[@]}"
            ;;
        kde|plasma)
            install_pm_pkg_bypass "${qt_pkgs[@]}"
            ;;
        xfce)
            install_pm_pkg_bypass \
                "${gtk_pkgs[@]}" \
                "${xfce_pkgs[@]}"
            ;;
        *)
            unsupported_desktop
            return 1
            ;;
    esac
}

install_gnome_distro_pkgs() {
    case "$os" in
        debian)
            if [ "$VERSION_ID" -ge 13 ]; then
                sudo apt-get install -y "${debian_gnome_pkgs[@]}" || return 1
            fi
            ;;
        ubuntu)
            if echo "$VERSION_ID >= 25.10" | bc -l | grep -Fq "1"; then
                sudo apt-get install -y "${debian_gnome_pkgs[@]}" || return 1
            fi
            ;;
        *)
            case " $os_like " in
                " debian ")
                    if [ "$VERSION_ID" -ge 13 ]; then
                        sudo apt-get install -y "${debian_gnome_pkgs[@]}" || return 1
                    fi
                    ;;
                *" ubuntu "*)
                    if echo "$VERSION_ID >= 25.10" | bc -l | grep -Fq "1"; then
                        sudo apt-get install -y "${debian_gnome_pkgs[@]}" || return 1
                    else
                        sudo apt-get install -y chrome-gnome-shell gnome-shell-extension-manager || return 1
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
                com.mattjakeman.ExtensionManager || return 1
            ;;
        *)
            flatpak install flathub -y com.github.tchx84.Flatseal || return 1
            ;;
    esac
}

disable_baloo() {
    local bin
    for bin in balooctl6 balooctl; do
        if command -v "$bin" >/dev/null 2>&1; then
            "$bin" disable
            return 0
        fi
    done
}

enable_xorg_vrr() {
    [ "$XDG_SESSION_TYPE" = "x11" ] || return 0
    [ "$amd_gpu_detected" -eq 1 ] || return 0

    if [ ! -f /etc/X11/xorg.conf.d/10-amdgpu.conf ]; then
        if confirm "Enable Xorg VRR? [y/N]"; then
            sudo cp "$HOME/Documents/linux_docs/configs/system/xorg/10-amdgpu.conf" \
                /etc/X11/xorg.conf.d/ || return 1
        fi
    fi
}

apply_desktop_adjustments() {
    case "$desktop" in
        kde|plasma)
            disable_baloo
            ;;
    esac

    enable_xorg_vrr
}

setup_desktop() {
    install_desktop_pkgs

    case "$desktop" in
        gnome|ubuntu)
            install_gnome_distro_pkgs
            ;;
    esac

    install_desktop_flatpaks
    apply_desktop_adjustments
}
