#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

ld_bash_dir="$HOME/Documents/linux_docs/configs/system/bash/bash.d"

shopt -s nullglob globstar
for file in "$ld_bash_dir"/**/*.sh; do
    [ -e "$file" ] || continue
    . "$file"
done
shopt -u nullglob globstar

detect_system
print_system_info

if [ "$swapfile_exists" -eq 1 ] && confirm "Remove swapfile? [y/N]"; then
    run_script "$LD_SCR/system/remove_swapfile.sh"

elif [ "$swapfile_exists" -eq 0 ] && [ "$swap_partition_exists" -eq 0 ] \
    && confirm "Create swapfile? [y/N]"; then
    run_script "$LD_SCR/system/create_swapfile.sh"
fi

exclude_from_array "flatpaks" "Flatpaks"

profile_choice=$(select_setup_profile)
[ -z "$profile_choice" ] && exit 0

case "$profile_choice" in
    default)
        firefox_browser="firefox"
        firefox_browser_uc="Firefox"

        chromium_browser=""
        chromium_browser_uc=""

        password_manager=""
        password_manager_uc=""

        office_suite="libreoffice"
        office_suite_uc="LibreOffice"

        if is_qt_preferred_env "$desktop"; then
            text_editor="kwrite"
            text_editor_uc="KWrite"
        else
            text_editor="gnome-text-editor"
            text_editor_uc="GNOME Text Editor"
        fi

        if is_qt_preferred_env "$desktop"; then
            media_player="haruna"
            media_player_uc="Haruna"
        else
            media_player="celluloid"
            media_player_uc="Celluloid"
        fi

        video_editor=""
        video_editor_uc=""

        torrent_client=""
        torrent_client_uc=""

        vm_application=""
        vm_application_uc=""
        ;;
    personal)
        firefox_browser="firefox"
        firefox_browser_uc="Firefox"

        chromium_browser="brave"
        chromium_browser_uc="Brave"

        password_manager="bitwarden"
        password_manager_uc="Bitwarden"

        office_suite="libreoffice"
        office_suite_uc="LibreOffice"

        if is_qt_preferred_env "$desktop"; then
            text_editor="kwrite"
            text_editor_uc="KWrite"
        else
            text_editor="gnome-text-editor"
            text_editor_uc="GNOME Text Editor"
        fi

        media_player=""
        media_player_uc=""

        video_editor=""
        video_editor_uc=""

        torrent_client="qbittorrent"
        torrent_client_uc="qBittorrent"

        vm_application="gnome-boxes"
        vm_application_uc="GNOME Boxes"
        ;;
    custom)
        result=$(select_firefox_browser)
        firefox_browser="${result%%|*}"
        firefox_browser_uc="${result#*|}"

        result=$(select_chromium_browser)
        chromium_browser="${result%%|*}"
        chromium_browser_uc="${result#*|}"

        result=$(select_password_manager)
        password_manager="${result%%|*}"
        password_manager_uc="${result#*|}"

        result=$(select_office_suite)
        office_suite="${result%%|*}"
        office_suite_uc="${result#*|}"

        result=$(select_text_editor)
        text_editor="${result%%|*}"
        text_editor_uc="${result#*|}"

        result=$(select_media_player)
        media_player="${result%%|*}"
        media_player_uc="${result#*|}"

        result=$(select_video_editor)
        video_editor="${result%%|*}"
        video_editor_uc="${result#*|}"

        result=$(select_torrent_client)
        torrent_client="${result%%|*}"
        torrent_client_uc="${result#*|}"

        result=$(select_vm_application)
        vm_application="${result%%|*}"
        vm_application_uc="${result#*|}"
        ;;
esac

print_field "Firefox Browser" "$firefox_browser_uc"
print_field "Chromium Browser" "$chromium_browser_uc"
print_field "Password Manager" "$password_manager_uc"
print_field "Office Suite" "$office_suite_uc"
print_field "Text Editor" "$text_editor_uc"
print_field "Media Player" "$media_player_uc"
print_field "Video Editor" "$video_editor_uc"
print_field "Torrent Client" "$torrent_client_uc"
print_field "Virtual Machine Application" "$vm_application_uc"

remove_non_selected_pkgs=0
install_codecs=0
install_redshift=0
install_gaming_pkgs=0

declare -A prompts=(
    [remove_non_selected_pkgs]="Remove non-selected packages if installed? [y/N]"
    [install_redshift]="Install redshift? [y/N]"
    [install_gaming_pkgs]="Install gaming packages? [y/N]"
)

ordered_prompt_vars=(
    remove_non_selected_pkgs
    install_redshift
    install_gaming_pkgs
)

for var in "${ordered_prompt_vars[@]}"; do
    if confirm "${prompts[$var]}"; then
        printf -v "$var" '%s' 1
    fi
done

queued_removals=()
queued_installs=()

for var in "${ordered_prompt_vars[@]}"; do
    if [ "${!var}" -eq 1 ]; then
        case "$var" in
            remove_non_selected_pkgs)
                queued_removals+=("non-selected pkgs")
                ;;
            install_*)
                pkg=${var#install_}
                pkg=${pkg//_/ }
                queued_installs+=("$pkg")
                ;;
        esac
    fi
done

if [ "${#queued_removals[@]}" -gt 0 ]; then
    printf -v joined '%s, ' "${queued_removals[@]}"
    joined=${joined%, }
    print_field "Queued removal" "$joined"
fi

if [ "${#queued_installs[@]}" -gt 0 ]; then
    printf -v joined '%s, ' "${queued_installs[@]}"
    joined=${joined%, }
    print_field "Queued install" "$joined"
fi

confirm_proceed

ensure_wheel_membership
configure_sudo

if [ -f /run/ostree-booted ]; then
    apply_btrfs_cow_policies

elif [ "$root_fs" = "btrfs" ] \
    || [ "$home_fs" = "btrfs" ] \
    || [ "$var_fs" = "btrfs" ]; then

    if confirm "Set up btrfs subvolumes? [y/N]"; then
        run_script "$LD_SCR/system/setup_btrfs_subvolumes.sh"
    else
        apply_btrfs_cow_policies
    fi
fi

make_keys() {
    local category="$1"

    local native="${category}_native_pkgs"
    local flatpak="${category}_flatpak_pkgs"
    local snap="${category}_snap_pkgs"
    local keys="${category}_keys"

    local -n n="$native"
    local -n f="$flatpak"
    local -n s="$snap"
    local -n k="$keys"

    # shellcheck disable=SC2034
    k=("${!n[@]}" "${!f[@]}" "${!s[@]}")
}

make_keys "firefox"
make_keys "chromium"
make_keys "password_manager"
make_keys "office_suite"
make_keys "text_editor"
make_keys "media_player"
make_keys "video_editor"
make_keys "torrent_client"
make_keys "vm_application"

if [ "$remove_non_selected_pkgs" -eq 1 ]; then
    remove_non_selected_pkg "firefox"          "$firefox_browser"      "${firefox_keys[@]}"
    remove_non_selected_pkg "chromium"         "$chromium_browser"     "${chromium_keys[@]}"
    remove_non_selected_pkg "password_manager" "$password_manager"     "${password_manager_keys[@]}"
    remove_non_selected_pkg "office_suite"     "$office_suite"         "${office_suite_keys[@]}"
    remove_non_selected_pkg "text_editor"      "$text_editor"          "${text_editor_keys[@]}"
    remove_non_selected_pkg "media_player"     "$media_player"         "${media_player_keys[@]}"
    remove_non_selected_pkg "video_editor"     "$video_editor"         "${video_editor_keys[@]}"
    remove_non_selected_pkg "torrent_client"   "$torrent_client"       "${torrent_client_keys[@]}"
    remove_non_selected_pkg "vm_application"   "$vm_application"       "${vm_application_keys[@]}"
fi

if [ "$firefox_browser" = "firefox" ]; then
    drop_pkg "firefox"
fi

if [ "$chromium_browser" = "chromium" ]; then
    drop_pkg "chromium"
fi

clean "auto"
upgrade "auto"

case "$os" in
    arch)
        confirm "Enable Chaotic AUR? [y/N]" && enable_chaotic_aur
        ;;
    ubuntu)
        ;;
    debian)
        enable_debian_contrib
        enable_debian_backports
        ;;
    *)
        case " $os_like " in
            *" arch "* )
                confirm "Enable Chaotic AUR? [y/N]" && enable_chaotic_aur
                ;;
            *" ubuntu "*)
                ;;
            *" debian "*)
                enable_debian_contrib
                enable_debian_backports
                ;;
        esac
    ;;
esac

install_primary_packages
install_fonts_microsoft

if ! grep -Fq "deno.bash" "$HOME/.bashrc"; then
    curl -fsSL https://deno.land/install.sh | sh
fi

case "$init_system" in
    systemd)
        if [ "$ram_gib" -gt 8 ] && systemctl status systemd-oomd.service >/dev/null 2>&1; then
            enable_service "systemd-oomd.service"
            disable_service "earlyoom.service" 2>/dev/null || :
        else
            disable_service "systemd-oomd.service" 2>/dev/null || :
            ensure_pkg "earlyoom" && configure_earlyoom
        fi
        ;;
    *)
        ensure_pkg "earlyoom" && configure_earlyoom
        ;;
esac

case "$os" in
    fedora)
        if [ "$toolbox_installed" -eq -1 ]; then
            if ! toolbox list | grep -Fq "fedora-toolbox-$VERSION_ID"; then
                toolbox create --distro fedora --release "$VERSION_ID"
            fi

            toolbox run sudo dnf upgrade -y
            toolbox run sudo dnf install -y "${toolbox_pkgs[@]}"
        fi
        ;;
esac

if [ "$btrfs_detected" -eq 1 ]; then
    ensure_pkg "compsize"

    case "$init_system" in
        systemd)
            if ensure_pkg "btrfsmaintenance"; then
                configure_btrfsmaintenance
            fi
            ;;
    esac
fi

ensure_pkg "flatpak" && flatpak_installed=1
[ "$flatpak_installed" -eq 1 ] && configure_flatpak

install_codecs

if [ "${#flatpaks[@]}" -ne 0 ]; then
    install_flatpak_pkg_bypass "${resolved_flatpaks[@]}"
fi

[ -n "$firefox_browser" ]   && install_selection "$firefox_browser"     "category_firefox"
[ -n "$chromium_browser" ]  && install_selection "$chromium_browser"    "category_chromium"
[ -n "$password_manager" ]  && install_selection "$password_manager"    "category_password_manager"
[ -n "$office_suite" ]      && install_selection "$office_suite"        "category_office_suite"
[ -n "$video_editor" ]      && install_selection "$video_editor"        "category_video_editor"
[ -n "$text_editor" ]       && install_selection "$text_editor"         "category_text_editor"
[ -n "$media_player" ]      && install_selection "$media_player"        "category_media_player"
[ -n "$torrent_client" ]    && install_selection "$torrent_client"      "category_torrent_client"
[ -n "$vm_application" ]    && install_selection "$vm_application"      "category_vm_application"

case "$torrent_client" in
    transmission)   configure_transmission ;;
    qbittorrent)    configure_qbittorrent ;;
esac

setup_desktop

[ "$install_redshift" -eq 1 ]       && ensure_pkg "redshift-gtk"
[ "$install_gaming_pkgs" -eq 1 ]    && run_script "$LD_SCR/gaming/setup_gaming.sh"

optimize_boot
enable_permanent_mac_address
add_firewall_exceptions

if [ "$battery_detected" -eq 1 ]; then
    add_kernel_parameter "preempt=voluntary"
else
    add_kernel_parameter "preempt=full"
fi

apply_pm_config

run_script "$LD_SCR/system/copy_pkg_configs.sh"
run_script "$LD_SCR/sync/sync_bashd.sh"
    
green_message "Success:" "Setup is now complete. Reboot to apply all changes."
