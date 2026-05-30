# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_apply_userjs() {
    local overwrite="$1"
    local source="$2"
    local -a roots=("${!3}")
    local profiles=()
    local cap max root dir target

    skipped=0

    detect_system

    if [ "$ram_gib" -le 2 ]; then
        cap=32768
        max=1024
    elif [ "$ram_gib" -le 4 ]; then
        cap=65536
        max=2048
    elif [ "$ram_gib" -le 6 ]; then
        cap=98304
        max=2048
    else
        cap=131072
        max=2048
    fi

    for root in "${roots[@]}"; do
        [ -d "$root" ] || continue
        while IFS= read -r dir; do
            profiles+=("$dir")
        done < <(find "$root" -maxdepth 1 -type d -name '*.default-*')
    done

    if [ "${#profiles[@]}" -eq 0 ]; then
        skipped=1
        return 0
    fi

    for dir in "${profiles[@]}"; do
        target="$dir/user.js"
        copy_config "$overwrite" "$source" "$target"
        sed -i \
          -e "s/^user_pref(\"browser\.cache\.memory\.capacity\".*/user_pref(\"browser.cache.memory.capacity\", $cap);/" \
          -e "s/^user_pref(\"browser\.cache\.memory\.max_entry_size\".*/user_pref(\"browser.cache.memory.max_entry_size\", $max);/" \
          "$target"
    done
}

configure_firefox() {
    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/applications/firefox/user.js"
    local -a roots=(
        "$HOME/.mozilla/firefox"
        "$HOME/.config/firefox"
        "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox"
        "$HOME/.var/app/org.mozilla.firefox/config/mozilla/firefox"
    )

    _apply_userjs "$overwrite" "$source" roots[@]

    if [ "$skipped" -eq 0 ]; then
        success_configs+=("firefox")
    else
        skipped_configs+=("firefox")
    fi
}

configure_librewolf() {
    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/applications/librewolf/user.js"

    local -a roots=(
        "$HOME/.librewolf"
        "$HOME/.mozilla/librewolf"
        "$HOME/.config/librewolf/librewolf"
        "$HOME/.var/app/io.gitlab.librewolf-community/.librewolf"
    )

    _apply_userjs "$overwrite" "$source" roots[@]

    if [ "$skipped" -eq 0 ]; then
        success_configs+=("librewolf")
    else
        skipped_configs+=("librewolf")
    fi
}

_configure_brave_native() {
    local overwrite="${1:-0}"
    local launch_args="$2"
    local brave_app brave_native

    brave_app="$HOME/.local/share/applications/brave-browser.desktop"
    brave_native="/usr/share/applications/brave-browser.desktop"

    if [ "$overwrite" -eq 1 ] || [ ! -f "$brave_app" ]; then
        rm -f "$brave_app"
        cat "$brave_native" > "$brave_app"
        sed -i "0,/^Exec=/s|^Exec=.*|Exec=/usr/bin/brave-browser-stable $launch_args %U|" "$brave_app"
        sed -i '/^\(GenericName\|Name\|Comment\)\[[^]]*\]=/d' "$brave_app"
    fi
}

_configure_brave_flatpak() {
    local overwrite="${1:-0}"
    local launch_args="$2"
    local brave_app brave_flatpak_sys brave_flatpak_user

    brave_app="$HOME/.local/share/applications/com.brave.Browser.desktop"
    brave_flatpak_sys="/var/lib/flatpak/exports/share/applications/com.brave.Browser.desktop"
    brave_flatpak_user="$HOME/.local/share/flatpak/exports/share/applications/com.brave.Browser.desktop"

    if [ "$overwrite" -eq 1 ] || [ ! -f "$brave_app" ]; then
        rm -f "$brave_app"

        if [ -f "$brave_flatpak_sys" ]; then
            cat "$brave_flatpak_sys" > "$brave_app"
        elif [ -f "$brave_flatpak_user" ]; then
            cat "$brave_flatpak_user" > "$brave_app"
        fi

        sed -i "0,/^Exec=/s|^Exec=.*|Exec=/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=brave --file-forwarding com.brave.Browser $launch_args @@u %U @@|" "$brave_app"
        sed -i '' '/^\(GenericName\|Name\|Comment\)\[[^]]*\]=/d' "$brave_app"
    fi
}

configure_brave() {
    local overwrite="${1:-0}"
    local launch_args=""
    local dir

    skipped=0

    detect_system

    if [ "$tmp_fs" = "tmpfs" ]; then
        dir="/tmp"
    else
        dir="/dev/shm"
    fi

    mkdir -p "$HOME/.local/share/applications"
    mkdir -p "$dir/brave-cache"
    launch_args="--disk-cache-dir=$dir/brave-cache --media-cache-dir=$dir/brave-cache --disk-cache-size=134217728"

    if command -v brave-browser >/dev/null 2>&1; then
        _configure_brave_native "$overwrite" "$launch_args"
    elif flatpak list --app --columns=app 2>/dev/null | grep -Fq "com.brave.Browser"; then
        _configure_brave_flatpak "$overwrite" "$launch_args"
    else
        skipped_configs+=("brave")
        return 0
    fi

    success_configs+=("brave")
}

configure_micro() {
    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/applications/micro/settings.json"
    local target="$HOME/.config/micro/settings.json"

    copy_config "$overwrite" "$source" "$target"
    success_configs+=("micro")
}

configure_nano() {
    local overwrite="${1:-0}"
    local source="$HOME/Documents/linux_docs/configs/applications/nanorc"
    local target="$HOME/.config/nano/nanorc"
    local sys_target="/etc/nanorc"

    copy_config "$overwrite" "$source" "$target"
    copy_config "$overwrite" "$source" "$sys_target"
    success_configs+=("nano")
}
