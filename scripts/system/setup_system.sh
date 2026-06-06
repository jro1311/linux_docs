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

profile_choice=$(select_setup_profile)
[ -z "$profile_choice" ] && exit 0

case "$profile_choice" in
    default)
        firefox_browser="firefox"
        firefox_browser_label="Firefox"

        chromium_browser=""
        chromium_browser_label=""

        password_manager=""
        password_manager_label=""

        office_suite="libreoffice"
        office_suite_label="LibreOffice"

        if is_qt_preferred_env "$desktop"; then
            text_editor="kwrite"
            text_editor_label="KWrite"
        else
            text_editor="gnome-text-editor"
            text_editor_label="GNOME Text Editor"
        fi

        if is_qt_preferred_env "$desktop"; then
            media_player="haruna"
            media_player_label="Haruna"
        else
            media_player="celluloid"
            media_player_label="Celluloid"
        fi

        image_editor=""
        image_editor_label=""

        video_editor=""
        video_editor_label=""

        torrent_client=""
        torrent_client_label=""

        vm_application=""
        vm_application_label=""
        ;;
    personal)
        firefox_browser="firefox"
        firefox_browser_label="Firefox"

        chromium_browser="brave"
        chromium_browser_label="Brave"

        password_manager="bitwarden"
        password_manager_label="Bitwarden"

        office_suite="libreoffice"
        office_suite_label="LibreOffice"

        if is_qt_preferred_env "$desktop"; then
            text_editor="kwrite"
            text_editor_label="KWrite"
        else
            text_editor="gnome-text-editor"
            text_editor_label="GNOME Text Editor"
        fi

        media_player=""
        media_player_label=""

        image_editor=""
        image_editor_label=""

        video_editor=""
        video_editor_label=""

        torrent_client="qbittorrent"
        torrent_client_label="qBittorrent"

        vm_application="gnome-boxes"
        vm_application_label="GNOME Boxes"
        ;;
    custom)
        result=$(select_firefox_browser)
        firefox_browser="${result%%|*}"
        firefox_browser_label="${result#*|}"

        result=$(select_chromium_browser)
        chromium_browser="${result%%|*}"
        chromium_browser_label="${result#*|}"

        result=$(select_password_manager)
        password_manager="${result%%|*}"
        password_manager_label="${result#*|}"

        result=$(select_office_suite)
        office_suite="${result%%|*}"
        office_suite_label="${result#*|}"

        result=$(select_text_editor)
        text_editor="${result%%|*}"
        text_editor_label="${result#*|}"

        result=$(select_media_player)
        media_player="${result%%|*}"
        media_player_label="${result#*|}"

        result=$(select_image_editor)
        image_editor="${result%%|*}"
        image_editor_label="${result#*|}"

        result=$(select_video_editor)
        video_editor="${result%%|*}"
        video_editor_label="${result#*|}"

        result=$(select_torrent_client)
        torrent_client="${result%%|*}"
        torrent_client_label="${result#*|}"

        result=$(select_vm_application)
        vm_application="${result%%|*}"
        vm_application_label="${result#*|}"
        ;;
esac

print_field "Firefox Browser" "$firefox_browser_label"
print_field "Chromium Browser" "$chromium_browser_label"
print_field "Password Manager" "$password_manager_label"
print_field "Office Suite" "$office_suite_label"
print_field "Text Editor" "$text_editor_label"
print_field "Media Player" "$media_player_label"
print_field "Image Editor" "$image_editor_label"
print_field "Video Editor" "$video_editor_label"
print_field "Torrent Client" "$torrent_client_label"
print_field "Virtual Machine Application" "$vm_application_label"

exclude_from_array "flatpaks" "Optional Flatpaks"

remove_non_selected_pkgs=0
remove_swapfile=0
setup_swapfile=0
setup_btrfs_subvolumes=0
setup_chaotic_aur=0
setup_packman_repo=0
configure_autostart_transmission=0
configure_autostart_qbittorrent=0
configure_disable_baloo=0
configure_overwrite_configs=0
configure_btop_network_limits=0
configure_compression_algorithm=0
install_tlp=0
install_redshift=0
install_gaming_pkgs=0

declare -A prompts=(
    [remove_non_selected_pkgs]="Remove non-selected packages if installed? [y/N]"
    [configure_overwrite_configs]="Overwrite existing package configs? [y/N]"
    [configure_btop_network_limits]="Run a speedtest to set btop network limits? [y/N]"
    [install_gaming_pkgs]="Install gaming packages? [y/N]"
)

if [ "$swapfile_exists" -eq 1 ]; then
    prompts[remove_swapfile]="Remove swapfile? [y/N]"

elif [ "$swapfile_exists" -eq 0 ] && [ "$swap_partition_exists" -eq 0 ]; then
    prompts[setup_swapfile]="Create swapfile? [y/N]"
fi

if [ ! -f /run/ostree-booted ] && \
    { [ "$root_fs" = "btrfs" ] \
    || [ "$home_fs" = "btrfs" ] \
    || [ "$var_fs" = "btrfs" ]; }; then

    prompts[setup_btrfs_subvolumes]="Set up btrfs subvolumes? [y/N]"
fi

case "$primary_pm" in
    pacman) prompts[setup_chaotic_aur]="Enable Chaotic AUR? [y/N]" ;;
    zypper) prompts[setup_packman_repo]="Enable packman repo and install multimedia codecs? [y/N]" ;;
esac

case "$desktop" in
    plasma) prompts[configure_disable_baloo]="Disable Baloo file indexing? [y/N]" ;;
esac

case "$torrent_client" in
    transmission)   prompts[configure_autostart_transmission]="Start Transmission at login? [y/N]" ;;
    qbittorrent)    prompts[configure_autostart_qbittorrent]="Start qBittorrent at login? [y/N]" ;;
esac

if [ "$battery_detected" -eq 1 ]; then
    prompts[install_tlp]="Install TLP? [y/N]"
fi

case "$desktop" in
    plasma|gnome|cinnamon|budgie) ;;
    *) prompts[install_redshift]="Install redshift? [y/N]" ;;
esac

ordered_prompt_vars=(
    remove_non_selected_pkgs
    remove_swapfile
    setup_swapfile
    setup_btrfs_subvolumes
    setup_chaotic_aur
    setup_packman_repo
    configure_autostart_transmission
    configure_autostart_qbittorrent
    configure_disable_baloo
    configure_overwrite_configs
    configure_btop_network_limits
    configure_compression_algorithm
    install_tlp
    install_redshift
    install_gaming_pkgs
)

for var in "${ordered_prompt_vars[@]}"; do
    if [ -n "${prompts[$var]+_}" ] && confirm "${prompts[$var]}"; then
        printf -v "$var" '%s' 1
    fi
done

if [ "$install_gaming_pkgs" -eq 1 ]; then
    result=$(select_gpu_config_tool)
    gpu_config_tool="${result%%|*}"
    gpu_config_tool_label="${result#*|}"

    print_field "GPU Configuration Tool" "$gpu_config_tool_label"
fi

queued_removals=()
queued_setup=()
queued_configure=()
queued_installs=()

for var in "${ordered_prompt_vars[@]}"; do
    if [ "${!var}" -eq 1 ]; then
        case "$var" in
            remove_non_selected_pkgs)
                queued_removals+=("non-selected pkgs")
                ;;
            remove_*)
                pkg=${var#remove_}
                pkg=${pkg//_/ }
                queued_removals+=("$pkg")
                ;;
            setup_*)
                pkg=${var#setup_}
                pkg=${pkg//_/ }
                queued_setup+=("$pkg")
                ;;
            configure_*)
                pkg=${var#configure_}
                pkg=${pkg//_/ }
                queued_configure+=("$pkg")
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

if [ "${#queued_setup[@]}" -gt 0 ]; then
    printf -v joined '%s, ' "${queued_setup[@]}"
    joined=${joined%, }
    print_field "Queued setup" "$joined"
fi

if [ "${#queued_configure[@]}" -gt 0 ]; then
    printf -v joined '%s, ' "${queued_configure[@]}"
    joined=${joined%, }
    print_field "Queued configure" "$joined"
fi

if [ "${#queued_installs[@]}" -gt 0 ]; then
    printf -v joined '%s, ' "${queued_installs[@]}"
    joined=${joined%, }
    print_field "Queued install" "$joined"
fi

confirm "Proceed? [y/N]"

ensure_wheel_membership
configure_sudo

if [ "$remove_swapfile" -eq 1 ]; then
    run_script "$LD_SCR/system/remove_swapfile.sh"

elif [ "$setup_swapfile" -eq 1 ]; then
    run_script "$LD_SCR/system/create_swapfile.sh"
fi

case "$init_system" in
    systemd)
        if ! grep -Fq "compress=zstd:1" /etc/fstab; then
            sudo sed -i 's/compress\(-force\)\?=[^, ]*/compress=zstd:1/' /etc/fstab
            sudo systemctl daemon-reload
        fi
        ;;
esac

if [ "$setup_btrfs_subvolumes" -eq 1 ]; then
    run_script "$LD_SCR/system/setup_btrfs_subvolumes.sh"

elif [ "$root_fs" = "btrfs" ] \
    || [ "$home_fs" = "btrfs" ] \
    || [ "$var_fs" = "btrfs" ]; then

    apply_btrfs_cow_policies
fi

if [ "$root_fs" = "btrfs" ]; then
    sudo mount -o remount,noatime,compress=zstd:1 /

elif [ "$root_fs" = "f2fs" ]; then
    sudo mount -o remount,noatime,compress_algorithm=zstd:1 /
else
    sudo mount -o remount,noatime /
fi

if [ "$boot_drive" = "hdd" ] && [ "$root_fs" = "btrfs" ]; then
    sudo mount -o remount,autodefrag /
fi

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
    remove_non_selected_pkg "image_editor"     "$image_editor"         "${image_editor_keys[@]}"
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

clean_bypass
upgrade_bypass

case "$os" in
    arch)
        [ "$setup_chaotic_aur" -eq 1 ] && enable_chaotic_aur
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
                [ "$setup_chaotic_aur" -eq 1 ] && enable_chaotic_aur
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
            toolbox run sudo dnf install -y "${toolbox_pkgs[@]}" >/dev/null
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

install_codecs "$setup_packman_repo"

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
    transmission)
        if [ "$configure_autostart_transmission" -eq 1 ]; then
            configure_transmission "$configure_autostart_transmission"
        fi
        ;;
    qbittorrent)
        if [ "$configure_autostart_qbittorrent" -eq 1 ]; then
            configure_qbittorrent "$configure_autostart_qbittorrent"
        fi
        ;;
esac

setup_desktop "$configure_disable_baloo"

[ "$install_tlp" -eq 1 ]         && ensure_pkg "tlp" && configure_tlp
[ "$install_redshift" -eq 1 ]    && ensure_pkg "redshift-gtk"

if [ "$install_gaming_pkgs" -eq 1 ]; then
    run_script "$LD_SCR/gaming/setup_gaming.sh" -- \
        "$gpu_config_tool" \
        "$remove_non_selected_pkgs"
fi

optimize_boot
enable_permanent_mac_address
add_firewall_exceptions

if [ "$battery_detected" -eq 1 ]; then
    add_kernel_parameter "preempt=voluntary"
else
    add_kernel_parameter "preempt=full"
fi

apply_pm_config

run_script "$LD_SCR/system/copy_pkg_configs.sh" -- \
    "$configure_overwrite_configs" \
    "$configure_btop_network_limits" \
    "$configure_compression_algorithm"

run_script "$LD_SCR/sync/sync_bashd.sh"
    
green_message "Success:" "System setup is complete."
yellow_message "Reboot required:" "Reboot to apply all changes."
