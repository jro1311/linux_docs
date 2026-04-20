#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Sources all .sh files in bashrc.d
shopt -s globstar nullglob

for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f "$rc" ]] && source "$rc"
done
unset rc

shopt -u globstar nullglob

detect_system

# Installs missing packages
packages=("rsync" "curl" "jq")
for package in "${packages[@]}"; do
    inverse_check "$package" \
        install_packages "$package"
done

path_prefix="$HOME/Documents/linux_docs/configs"

configs=(
    "$path_prefix/applications/btop.conf" "$HOME/.config/btop/"
    "$path_prefix/applications/htoprc" "$HOME/.config/htop/"
    "$path_prefix/applications/micro/settings.json" "$HOME/.config/micro/"
    "$path_prefix/applications/mpv" "$HOME/.config/"
    "$path_prefix/applications/mpv" "$HOME/.var/app/io.mpv.Mpv/config/"
    "$path_prefix/applications/nanorc" "$HOME/.config/nano/"
    "$path_prefix/applications/nanorc" "/etc/"
    "$path_prefix/system/fontconfig/fonts.conf" "$HOME/.config/fontconfig/"
)

for ((i=0; i<${#configs[@]}; i+=2)); do
    source="${configs[i]}"
    target="${configs[i+1]}"
    copy_config "$source" "$target"
done

# Switches mpv profile from high-quality to fast when on battery
if [ "$battery_detected" -eq 1 ]; then
    sed -i 's/profile=high-quality/profile=fast/' "$HOME/.config/mpv/mpv.conf"
    sed -i 's/profile=high-quality/profile=fast/' "$HOME/.var/app/io.mpv.Mpv/config/mpv/mpv.conf"
fi

file=""
if ls /dev/zram* >/dev/null 2>&1; then
    file="zram"
    case "$init_system" in
        "systemd")
            copy_config "$path_prefix/system/zram/zram-generator.conf" /etc/systemd/

            # Switches compression algorithm from zstd to lz4 when on battery
            if [ "$battery_detected" -eq 1 ]; then
                sudo sed -i 's/zstd/lz4/g' /etc/systemd/zram-generator.conf
            fi

            sudo systemctl daemon-reload
            ;;
    esac

    # Switches swap meter with zram in htop
    if [ -f "$HOME/.config/htop/htoprc" ]; then
        sed -i 's/Swap/Zram/g' "$HOME/.config/htop/htoprc"
    fi

elif [ "$swap_detected" -eq 1 ]; then
    file="swap"
fi

if [ -n "$file" ]; then
    copy_config "$path_prefix/system/zram/99-$file.conf" /etc/sysctl.d/
    sudo sysctl -p "/etc/sysctl.d/99-$file.conf"
fi

if command -v mangohud >/dev/null 2>&1; then
    copy_config "$path_prefix/applications/MangoHud.conf" "$HOME/.config/MangoHud/"

    if [ "$display_cmd" = "unknown" ]; then
        read -er -p "Enter display refresh rate: " refresh_rate

        if [ -z "$refresh_rate" ]; then
            red_message "Error:" "'$refresh_rate' is empty"
            exit 1
        fi

        max_fps_target=$(awk "BEGIN {printf \"%.0f\", int(($refresh_rate - 5) / 10 + 0.5) * 10}")
    fi

    if [ "$refresh_rate" -le 55 ]; then
        fps_list="$max_fps_target,0"

    elif [ "$refresh_rate" -le 60 ]; then
        fps_list="$max_fps_target,30,0"

    elif [ "$refresh_rate" -le 75 ]; then
        fps_list="$max_fps_target,60,30,0"

    elif [ "$refresh_rate" -le 90 ]; then
        fps_list="$max_fps_target,75,60,30,0"

    elif [ "$refresh_rate" -le 100 ]; then
        fps_list="$max_fps_target,90,75,60,30,0"

    elif [ "$refresh_rate" -le 120 ]; then
        fps_list="$max_fps_target,100,90,75,60,30,0"

    elif [ "$refresh_rate" -le 180 ]; then
        fps_list="$max_fps_target,120,100,90,75,60,30,0"

    elif [ "$refresh_rate" -le 240 ]; then
        fps_list="$max_fps_target,180,120,100,90,75,60,30,0"

    elif [ "$refresh_rate" -le 360 ]; then
        fps_list="$max_fps_target,240,180,120,100,90,75,60,30,0"

    elif [ "$refresh_rate" -le 480 ]; then
        fps_list="$max_fps_target,360,240,180,120,100,90,75,60,30,0"

    elif [ "$refresh_rate" -gt 480 ]; then
        fps_list="$max_fps_target,480,360,240,180,120,100,90,75,60,30,0"
    fi

    sed -i '/^fps_limit=/ s/=.*$/=/' "$HOME/.config/MangoHud/MangoHud.conf"
    sed -i "s/^fps_limit=/fps_limit=$fps_list/" "$HOME/.config/MangoHud/MangoHud.conf"

    mkdir -pv "$HOME/Documents/mangohud/logs"
    if ! grep -Fq "output_folder" "$HOME/.config/MangoHud/MangoHud.conf"; then
        echo "output_folder=$HOME/Documents/mangohud/logs" >> "$HOME/.config/MangoHud/MangoHud.conf"
    fi
fi

if command -v redshift >/dev/null 2>&1; then
    copy_config "$path_prefix/applications/redshift/redshift.conf" "$HOME/.config/"
    copy_config "$path_prefix/applications/redshift/redshift.desktop" "$HOME/.config/autostart/"

    get_location

    sed -i '/^lat=/ s/=.*$/=/' "$HOME/.config/redshift.conf"
    sed -i '/^lon=/ s/=.*$/=/' "$HOME/.config/redshift.conf"
    echo "lat=$latitude" >> "$HOME/.config/redshift.conf"
    echo "lon=$longitude" >> "$HOME/.config/redshift.conf"

    sed -i '/^Exec=redshift/d' "$HOME/.config/autostart/redshift.desktop"
    echo "Exec=redshift" >> "$HOME/.config/autostart/redshift.desktop"

    if command -v redshift-gtk >/dev/null 2>&1; then
        sed -i 's/^Exec=redshift/Exec=redshift-gtk/' "$HOME/.config/autostart/redshift.desktop"
    fi
fi

green_message "Success:" "Synced all package configs with the system."
