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

is_qt_preferred_env() {
    local desktop="$1"

    if is_qt_desktop "$desktop" || is_window_manager "$desktop"; then
        return 0
    else
        return 1
    fi
}

install_desktop_pkgs() {
    case "$desktop" in
        gnome|xfce|lxde|cosmic|deepin|mate|budgie|pantheon|x-cinnamon|ubuntu|unity)
            ensure_pkg "${gtk_pkgs[@]}"
            ;;
        kde|plasma|lxqt|awesome|enlightenment|fluxbox|hyprland|i3|openbox|qtile|sway|xmonad|*wm)
            ensure_pkg "${qt_pkgs[@]}"
            ;;
        *)
            unsupported_desktop
            return 1
            ;;
    esac

    case "$desktop" in
        gnome|ubuntu)
            ensure_pkg "${gnome_pkgs[@]}"
            ;;
        xfce)
            ensure_pkg "${xfce_pkgs[@]}"
            ;;
    esac
}

install_gnome_distro_pkgs() {
    case "$os" in
        debian)
            if [ "$VERSION_ID" -ge 13 ]; then
                ensure_pkg "${debian_gnome_pkgs[@]}" || return 1
            fi
            ;;
        ubuntu)
            if echo "$VERSION_ID >= 25.10" | bc -l | grep -Fq "1"; then
                ensure_pkg "${debian_gnome_pkgs[@]}" || return 1
            fi
            ;;
        *)
            case " $os_like " in
                " debian ")
                    if [ "$VERSION_ID" -ge 13 ]; then
                        ensure_pkg "${debian_gnome_pkgs[@]}" || return 1
                    fi
                    ;;
                *" ubuntu "*)
                    if echo "$VERSION_ID >= 25.10" | bc -l | grep -Fq "1"; then
                        ensure_pkg "${debian_gnome_pkgs[@]}" || return 1
                    else
                        ensure_pkg "chrome-gnome-shell" "gnome-shell-extension-manager" || return 1
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
            if ! pkg_installed_flatpak "com.github.tchx84.Flatseal"; then
                install_flatpak_pkg_bypass "com.github.tchx84.Flatseal" || return 1
            fi

            if ! pkg_installed_flatpak "com.mattjakeman.ExtensionManager"; then
                install_flatpak_pkg_bypass "com.mattjakeman.ExtensionManager" || return 1
            fi
            ;;
        *)
            if ! pkg_installed_flatpak "com.github.tchx84.Flatseal"; then
                install_flatpak_pkg_bypass "com.github.tchx84.Flatseal" || return 1
            fi
            ;;
    esac
}

_determine_baloo_cmd() {
    baloo_cmd=""

    local -a cmds=(
        balooctl6
        balooctl
    )

    local cmd

    for cmd in "${cmds[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            baloo_cmd="$cmd"
            return 0
        fi
    done

    if [ -z "$baloo_cmd" ]; then
        red_message "Error:" "Could not define baloo command."
        return 1
    fi
}

disable_baloo() {
    _determine_baloo_cmd || return 1

    "$baloo_cmd" disable
    "$baloo_cmd" purge
}

_ensure_baloo_list_entry() {
    local key="$1"
    local value="$2"

    if ! "$baloo_cmd" config list "$key" | grep -Fq "$value"; then
        "$baloo_cmd" config add "$key" "$value"
    fi
}

configure_baloo() {
    _determine_baloo_cmd || return 1

    "$baloo_cmd" config set contentIndexing false
    "$baloo_cmd" config set hidden false

    _ensure_baloo_list_entry excludeFolders "$HOME"
    _ensure_baloo_list_entry includeFolders "$HOME/Documents"
    _ensure_baloo_list_entry includeFolders "$HOME/Pictures"
    _ensure_baloo_list_entry includeFolders "$HOME/Videos"
    _ensure_baloo_list_entry includeFolders "$HOME/Music"
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
    local setup_disable_baloo=${1:-}

    case "$desktop" in
        kde|plasma)
            setup_disable_baloo=$(resolve_flag \
                "$setup_disable_baloo" \
                "Disable Baloo file indexing? [y/N]")

            if [ "$setup_disable_baloo" -eq 1 ]; then
                disable_baloo
            else
                configure_baloo
            fi

            sed -i \
                -e 's/AnimationDurationFactor=.*/AnimationDurationFactor=0.35355339059327373/' \
                -e 's/LookAndFeelPackage=.*/LookAndFeelPackage=org.kde.breezedark.desktop/' \
                "$HOME/.config/kdeglobals"
            ;;
    esac
}

setup_desktop() {
    local setup_disable_baloo=${1:-}
    install_desktop_pkgs

    case "$desktop" in
        gnome|ubuntu)
            install_gnome_distro_pkgs
            ;;
    esac

    install_desktop_flatpaks
    apply_desktop_adjustments "$setup_disable_baloo"
}
