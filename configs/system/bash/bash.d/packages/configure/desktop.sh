# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_configure_kwinrc() {
    local overwrite="$1"
    local source="$HOME/Documents/linux_docs/configs/system/plasma/kwinrc"
    local target="$HOME/.config/kwinrc"

    copy_config "$overwrite" "$source" "$target"
}

_configure_ksmserverrc() {
    local overwrite="$1"
    local source="$HOME/Documents/linux_docs/configs/system/plasma/ksmserverrc"
    local target="$HOME/.config/ksmserverrc"

    copy_config "$overwrite" "$source" "$target"
}

_configure_plasma_panel() {
    local overwrite="$1"
    local source="$HOME/Documents/linux_docs/configs/system/plasma/plasma-org.kde.plasma.desktop-appletsrc"
    local target="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
    local joined
    local -a apps=(
        applications:org.kde.konsole.desktop
        applications:org.kde.plasma-systemmonitor.desktop
        applications:systemsettings.desktop
        applications:org.kde.discover.desktop
        preferred://filemanager
        preferred://texteditor
        preferred://browser
    )

    if [ "$overwrite" -eq 1 ] || [ ! -f "$target" ]; then
        copy_config "$overwrite" "$source" "$target"

        joined=$(printf "%s," "${apps[@]}")
        joined="${joined%,}"

        sed -i "s|^launchers=.*|launchers=\"$joined\"|" "$target"
    else
        skipped_configs+=("plasma-org.kde.plasma.desktop-appletsrc")
    fi
}

configure_plasma() {
    local overwrite="${1:-0}"

    detect_system

    case "$desktop" in
        kde|plasma)
            _configure_kwinrc       "$overwrite"
            _configure_ksmserverrc  "$overwrite"
            _configure_plasma_panel "$overwrite"
            ;;
        *)
            skipped_configs+=(
                "kwinrc"
                "ksmserverrc"
                "plasma-org.kde.plasma.desktop-appletsrc"
            )
            ;;
    esac
}
