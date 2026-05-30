# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

configure_kwinrc() {
    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/system/plasma/kwinrc"
    local target="$HOME/.config/kwinrc"

    detect_system

    case "$desktop" in
        kde|plasma)
            copy_config "$overwrite" "$source" "$target"
            success_configs+=("kwinrc")
            ;;
        *)
            skipped_configs+=("kwinrc")
            ;;
    esac
}

configure_ksmserverrc() {
    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/system/plasma/ksmserverrc"
    local target="$HOME/.config/ksmserverrc"

    detect_system

    case "$desktop" in
        kde|plasma)
            copy_config "$overwrite" "$source" "$target"
            success_configs+=("ksmserverrc")
            ;;
        *)
            skipped_configs+=("ksmserverrc")
            ;;
    esac
}

configure_plasma_panel() {
    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/system/plasma/plasma-org.kde.plasma.desktop-appletsrc"
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
    )

    detect_system

    case "$desktop" in
        kde|plasma)
            if [ "$overwrite" -eq 1 ] || [ ! -f "$target" ]; then
                copy_config "$overwrite" "$source" "$target"

                joined=$(printf "%s," "${apps[@]}")
                joined="${joined%,}"

                sed -i "s|^launchers=.*|launchers=$joined|" "$target"
            fi

            success_configs+=("plasma panel")
            ;;
        *)
            skipped_configs+=("plasma panel")
            ;;
    esac
}
