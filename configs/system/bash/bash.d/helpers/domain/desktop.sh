# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

gtk_desktops=(
    gnome
    cosmic
    cinnamon
    mate
    xfce
    lxde
    budgie
    pantheon
    unity
    deepin
)

qt_desktops=(
    plasma
    lxqt
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
    if is_qt_preferred_env "$desktop"; then
        ensure_pkg "${qt_pkgs[@]}"
    else
        ensure_pkg "${gtk_pkgs[@]}"
    fi

    case "$desktop" in
        gnome)
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
        plasma)
            ;;
        gnome)
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

    "$baloo_cmd" enable
    "$baloo_cmd" config set contentIndexing false
    "$baloo_cmd" config set hidden false

    _ensure_baloo_list_entry excludeFolders "$HOME"
    _ensure_baloo_list_entry includeFolders "$HOME/Documents"
    _ensure_baloo_list_entry includeFolders "$HOME/Pictures"
    _ensure_baloo_list_entry includeFolders "$HOME/Videos"
    _ensure_baloo_list_entry includeFolders "$HOME/Music"
}

apply_desktop_adjustments() {
    local configure_disable_baloo=${1:-}

    case "$desktop" in
        plasma)
            configure_disable_baloo=$(resolve_flag \
                "$configure_disable_baloo" \
                "Disable Baloo file indexing? [y/N]")

            if [ "$configure_disable_baloo" -eq 1 ]; then
                disable_baloo
            else
                configure_baloo
            fi

            sed -i \
                -e 's/AnimationDurationFactor=.*/AnimationDurationFactor=0.5/' \
                -e 's/LookAndFeelPackage=.*/LookAndFeelPackage=org.kde.breezedark.desktop/' \
                "$HOME/.config/kdeglobals"
            ;;
    esac
}

setup_desktop() {
    local configure_disable_baloo=${1:-}
    install_desktop_pkgs

    case "$desktop" in
        gnome) install_gnome_distro_pkgs ;;
    esac

    install_desktop_flatpaks
    apply_desktop_adjustments "$configure_disable_baloo"
}
