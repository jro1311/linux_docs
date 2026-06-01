# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

select_git_repo() {
    green_message "GitHub Repositories:"
    printf '%s\n' \
        "[1] linux_docs" \
        "[2] custom" \
        "[x] cancel" \
        | sed "s/^/  /" >&2

    while true; do
        read -r -p "Select repo [1-2]: " num

        case "$num" in
            1) printf '%s' "linux_docs"; return 0 ;;
            2) printf '%s' "custom"; return 0 ;;
            x) return 0 ;;
            *) continue ;;
        esac
    done
}

select_swapfile_config() {
    green_message "Swapfile Configuration:"
    printf '%s\n' \
        "[1] auto-detect (recommended)" \
        "[2] custom" \
        "[x] cancel" \
        | sed "s/^/  /" >&2

    while true; do
        read -r -p "Select swapfile configuration option [1-2]: " num

        case "$num" in
            1) printf '%s' "auto-detect"; return 0 ;;
            2) printf '%s' "custom"; return 0 ;;
            x) return 0 ;;
            *) continue ;;
        esac
    done
}

exclude_from_array() {
    declare -n array="$1"
    local label=$2

    while true; do
        if [ "${#array[@]}" -eq 0 ]; then
            printf '%s' ""
            break
        fi

        green_message "$label:"

        local i=1
        local menu=""

        for fp in "${array[@]}"; do
            printf -v menu '%s[%d] %s\n' "$menu" "$i" "$fp"
            i=$((i+1))
        done

        printf -v menu '%s[x] none' "$menu"
        printf '%s\n' "$menu" | sed 's/^/  /' >&2

        read -r -p "Exclude from installation? [1-$((i-1)) or x]: " num

        case "$num" in
            [Xx]) break ;;
            ''|*[!0-9]*) continue ;;
        esac

        if [ "$num" -lt 1 ] || [ "$num" -gt "${#array[@]}" ]; then
            continue
        fi

        unset 'array[num-1]'
        array=("${array[@]}")
    done
}

select_firefox_browser() {
    green_message "Firefox Browsers:"
    printf '%s\n' \
        "[1] Firefox" \
        "[2] LibreWolf" \
        "[3] Floorp" \
        "[4] Zen" \
        "[5] Waterfox" \
        "[x] none" \
        | sed "s/^/  /" >&2

    while true; do
        read -r -p "Select a Firefox-based browser [1-6]: " num

        case "$num" in
            1) printf '%s|%s' "firefox" "Firefox" ;;
            2) printf '%s|%s' "librewolf" "LibreWolf" ;;
            3) printf '%s|%s' "floorp" "Floorp" ;;
            4) printf '%s|%s' "zen" "Zen" ;;
            5) printf '%s|%s' "waterfox" "Waterfox" ;;
            x) ;;
            *) continue ;;
        esac

        break
    done
}

select_chromium_browser() {
    green_message "Chromium Browsers:"
    printf '%s\n' \
        "[1] Brave" \
        "[2] Chromium" \
        "[3] Ungoogled Chromium" \
        "[4] Vivaldi" \
        "[5] Chrome" \
        "[6] Opera" \
        "[7] Opera GX" \
        "[x] none" \
        | sed "s/^/  /" >&2

    while true; do
        read -r -p "Select a Chromium-based browser [1-7]: " num

        case "$num" in
            1) printf '%s|%s' "brave" "Brave" ;;
            2) printf '%s|%s' "chromium" "Chromium" ;;
            3) printf '%s|%s' "ungoogled-chromium" "Ungoogled Chromium";;
            4) printf '%s|%s' "vivaldi" "Vivaldi";;
            5) printf '%s|%s' "chrome" "Chrome" ;;
            6) printf '%s|%s' "opera" "Opera" ;;
            7) printf '%s|%s' "opera-gx" "Opera GX" ;;
            x) ;;
            *) continue ;;
        esac

        break
    done
}

select_password_manager() {
    green_message "Password Managers:"
    printf '%s\n' \
        "[1] Bitwarden" \
        "[2] KeePassXC" \
        "[x] none" \
        | sed "s/^/  /" >&2

    while true; do
        read -r -p "Select a password manager [1-2]: " num

        case "$num" in
            1) printf '%s|%s' "bitwarden" "Bitwarden" ;;
            2) printf '%s|%s' "keepassxc" "KeePassXC" ;;
            x) printf '%s|%s' "" "" ;;
            *) continue ;;
        esac

        break
    done
}

select_office_suite() {
    green_message "Office Suites:"
    printf '%s\n' \
        "[1] LibreOffice" \
        "[2] OnlyOffice" \
        "[x] none" \
        | sed "s/^/  /" >&2

    while true; do
        read -r -p "Select an office suite [1-2]: " num

        case "$num" in
            1) printf '%s|%s' "libreoffice" "LibreOffice" ;;
            2) printf '%s|%s' "onlyoffice" "OnlyOffice" ;;
            x) printf '%s|%s' "" "" ;;
            *) continue ;;
        esac

        break
    done
}

select_text_editor() {
    green_message "Text Editors:"
    printf '%s\n' \
        "[1] GNOME Text Editor" \
        "[2] Kwrite" \
        "[3] Kate" \
        "[4] Mousepad" \
        "[5] Geany" \
        "[x] none" \
        | sed "s/^/  /" >&2

    while true; do
        read -r -p "Select a text editor [1-5]: " num

        case "$num" in
            1) printf '%s|%s' "gnome-text-editor" "GNOME Text Editor" ;;
            2) printf '%s|%s' "kwrite" "Kwrite" ;;
            3) printf '%s|%s' "kate" "Kate" ;;
            4) printf '%s|%s' "mousepad" "Mousepad" ;;
            5) printf '%s|%s' "geany" "Geany" ;;
            x) printf '%s|%s' "" "" ;;
            *) continue ;;
        esac

        break
    done
}

select_video_editor() {
    green_message "Video Editors:"
    printf '%s\n' \
        "[1] Shotcut" \
        "[2] Kdenlive" \
        "[x] none" \
        | sed "s/^/  /" >&2

    while true; do
        read -r -p "Select a video editor [1-2]: " num

        case "$num" in
            1) printf '%s|%s' "shotcut" "Shotcut" ;;
            2) printf '%s|%s' "kdenlive" "Kdenlive" ;;
            x) printf '%s|%s' "" "" ;;
            *) continue ;;
        esac

        break
    done
}

select_torrent_client() {
    green_message "Torrent Clients:"
    printf '%s\n' \
        "[1] Transmission" \
        "[2] qBittorrent" \
        "[x] none" \
        | sed "s/^/  /" >&2

    while true; do
        read -r -p "Select a torrent client [1-2]: " num

        case "$num" in
            1) printf '%s|%s' "transmission" "Transmission" ;;
            2) printf '%s|%s' "qbittorrent" "qBittorrent" ;;
            x) printf '%s|%s' "" "" ;;
            *) continue ;;
        esac

        break
    done
}

select_vm_application() {
    green_message "Virtual Machine Application:"
    printf '%s\n' \
        "[1] GNOME Boxes" \
        "[2] Virt-Manager" \
        "[x] none" \
        | sed "s/^/  /" >&2

    while true; do
        read -r -p "Select a virtual machine application [1-2]: " num

        case "$num" in
            1) printf '%s|%s' "gnome-boxes" "GNOME Boxes" ;;
            2) printf '%s|%s' "virt-manager" "Virt-Manager" ;;
            x) printf '%s|%s' "" "" ;;
            *) continue ;;
        esac

        break
    done
}

select_gpu_config_tool() {
    green_message "GPU Configuration Tools:"
    printf '%s\n' \
        "[1] LACT" \
        "[2] CoreCtrl" \
        "[x] none" \
        | sed "s/^/  /" >&2

    while true; do
        read -r -p "Select tool [1-2]: " num

        case "$num" in
            1) printf '%s|%s' "lact" "LACT" ;;
            2) printf '%s|%s' "corectrl" "CoreCtrl" ;;
            x) ;;
            *) continue ;;
        esac

        break
    done
}

select_indentation_format() {
    green_message "Formats:"
    printf '%s\n' \
        "[1] Tabs" \
        "[2] Spaces" \
        "[x] cancel" \
        | sed "s/^/  /" >&2

    while true; do
        read -r -p "Select format to convert to [1-2]: " num

        case "$num" in
            1) printf '%s|%s\n' "tabs" "unexpand" ;;
            2) printf '%s|%s\n' "spaces" "expand" ;;
            x) printf '%s|%s\n' "" "" ;;
            *) continue ;;
        esac

        break
    done
}
