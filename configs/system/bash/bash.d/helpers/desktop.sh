# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

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

qt_desktops=(
    lxqt
    kde
    plasma
)

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

all_desktops=(
    "${qt_desktops[@]}"
    "${gtk_desktops[@]}"
)

is_gtk_desktop() {
    local desktop=$1

    in_array "$desktop" "${gtk_desktops[@]}" && return 0
    return 1
}

is_qt_desktop() {
    local desktop=$1

    in_array "$desktop" "${qt_desktops[@]}" && return 0
    return 1
}

is_window_manager() {
    local desktop=$1

    in_array "$desktop" "${window_managers[@]}" && return 0
    case $desktop in
        *wm) return 0 ;;
    esac

    return 1
}

install_desktop_pkgs() {
    case "$desktop" in
        budgie|cosmic|deepin|gnome|lxde|mate|pantheon|ubuntu|unity|x-cinnamon|xfce)
            install_pm_pkg_bypass "${gtk_pkgs[@]}"
            ;;
        lxqt|kde|plasma|awesome|enlightenment|fluxbox|hyprland|i3|openbox|qtile|sway|xmonad|*wm)
            install_pm_pkg_bypass "${qt_pkgs[@]}"
            ;;
        *)
            unsupported_desktop
            return 1
            ;;
    esac

    case "$desktop" in
        gnome|ubuntu)
            install_pm_pkg_bypass "${gnome_pkgs[@]}"
            ;;
        xfce)
            install_pm_pkg_bypass "${xfce_pkgs[@]}"
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
    local source="$HOME/Documents/linux_docs/configs/system/xorg/10-amdgpu.conf"
    local target="/etc/X11/xorg.conf.d/10-amdgpu.conf"

    [ "$XDG_SESSION_TYPE" = "x11" ] || return 0
    [ "$amd_gpu_detected" -eq 1 ] || return 0

    if [ ! -f "$target" ] && confirm "Enable Xorg VRR? [y/N]"; then
        sudo cp "$source" "$target" || return 1
    fi
}

apply_desktop_adjustments() {
    case "$desktop" in
        kde|plasma)
            disable_baloo

            sed -i \
                -e 's/AnimationDurationFactor=.*/AnimationDurationFactor=0.35355339059327373/' \
                -e 's/LookAndFeelPackage=.*/LookAndFeelPackage=org.kde.breezedark.desktop/' \
                "$HOME/.config/kdeglobals"
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
