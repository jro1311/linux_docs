# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

configure_kwinrc() {
    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/system/desktop/kwinrc"
    local target="$HOME/.config/kwinrc"

    detect_system

    case "$desktop" in
        kde|plasma) ;;
        *) skipped=1; return 0 ;;
    esac

    copy_config "$overwrite" "$source" "$target"
}

configure_plasma_panel() {
    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/system/desktop/plasma-org.kde.plasma.desktop-appletsrc"
    local target="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
    local joined
    local apps=(
        applications:org.kde.konsole.desktop
        applications:org.kde.plasma-systemmonitor.desktop
        applications:systemsettings.desktop
        preferred://filemanager
        applications:org.kde.kate.desktop
        applications:org.kde.kwrite.desktop
        applications:org.kde.kcalc.desktop
        applications:org.kde.kclock.desktop
        applications:org.kde.kweather.desktop
        applications:org.kde.discover.desktop
        preferred://browser
    )

    detect_system

    case "$desktop" in
        kde|plasma) ;;
        *) skipped=1; return 0 ;;
    esac

    copy_config "$overwrite" "$source" "$target"

    joined=$(printf "%s," "${apps[@]}")
    joined="${joined%,}"

    sed -i "s|^launchers=.*|launchers=$joined|" "$target"
}
