# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

configure_kwinrc() {
    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/system/desktop/kwinrc"
    local target="$HOME/.config/kwinrc"

    skipped=0

    detect_system

    case "$desktop" in
        kde|plasma)
            copy_config "$overwrite" "$source" "$target"
            ;;
        *)
            yellow_message "Skipped:" "kwinrc"
            skipped=1
            return 0
            ;;
    esac
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
        applications:org.kde.discover.desktop
        preferred://filemanager
        preferred://texteditor
        preferred://browser
        applications:org.kde.kcalc.desktop
        applications:org.kde.kclock.desktop
        applications:org.kde.kweather.desktop
    )

    skipped=0

    detect_system

    case "$desktop" in
        kde|plasma)
            if [ "$overwrite" -eq 1 ] || [ ! -f "$target" ]; then
                copy_config "$overwrite" "$source" "$target"

                joined=$(printf "%s," "${apps[@]}")
                joined="${joined%,}"

                sed -i "s|^launchers=.*|launchers=$joined|" "$target"
            fi
            ;;
        *)
            yellow_message "Skipped:" "plasma panel"
            skipped=1
            return 0
            ;;
    esac
}
