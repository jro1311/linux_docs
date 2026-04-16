#!/usr/bin/env bash
# shellcheck disable=SC2154

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Sources all .sh files in $HOME/Documents/linux_docs/configs/system/bash/bashrc.d
shopt -s globstar nullglob

# shellcheck source=/dev/null
for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f "$rc" ]] && source "$rc"
done
unset rc
shopt -u globstar nullglob

detect_system

# Define path prefix
if command -v /usr/bin/steam >/dev/null 2>&1; then
    path_prefix="$HOME/.local/share/Steam/steamapps"

elif command -v flatpak >/dev/null 2>&1 && flatpak list --app --columns=app | grep -Fq "com.valvesoftware.Steam"; then
    path_prefix="$HOME/.var/app/com.valvesoftware.Steam/data/Steam/steamapps"

elif command -v /snap/bin/steam >/dev/null 2>&1; then
    path_prefix="$HOME/snap/steam/common/.steam/steam/steamapps"
else
    red_message "Steam not detected."
    exit 1
fi

# Prints system information
print_field "Display Resolution" "$display"
print_field "Display Refresh Rate" "$refresh_rate Hz"
print_field "Max FPS Target" "$max_fps_target FPS"

green_message "Supported Games:"
echo "[f4] Fallout 4
[fnv] Fallout New Vegas
[me] Mirror's Edge
[ja] Star Wars Jedi Knight: Jedi Academy
[tesiv] The Elder Scrolls IV: Oblivion
[tesv] The Elder Scrolls V: Skyrim
[tl] Torchlight"

read -er -p "Enter game: " game

tweaks_applied=0

case "$game" in
    "f4")
        files=(
            "$path_prefix/common/Fallout 4/Fallout4_Default.ini"
            "$path_prefix/common/Fallout 4/Fallout4/Fallout4Prefs.ini"
            "$path_prefix/compatdata/377160/pfx/drive_c/users/steamuser/My Documents/My Games/Fallout4/Fallout4Prefs.ini"
            "$path_prefix/compatdata/377160/pfx/drive_c/users/steamuser/My Documents/My Games/Fallout4/Fallout4.ini"
        )

        disable_dof=0
        disable_mouse_accel=0

        ask_for_confirmation "Disable depth of field?" && disable_dof=1
        ask_for_confirmation "Disable mouse acceleration?" && disable_mouse_accel=1

        for file in "${files[@]}"; do
            if [ ! -f "$file" ]; then
                yellow_message "Warning:" "'$file' does not exist."
                continue
            fi

            if [ "$disable_dof" -eq 1 ]; then
                sed -i \
                    -e 's/bDoDepthOfField=1/bDoDepthOfField=0/g' \
                    -e 's/bScreenSpaceBokeh=1/bScreenSpaceBokeh=0/g' "$file" \
                    && tweaks_applied=1
            fi

            if [ "$disable_mouse_accel" -eq 1 ]; then
                sed -i 's/bMouseAcceleration=1/bMouseAcceleration=0/g' "$file" \
                    && tweaks_applied=1
            fi
        done
        ;;
    "fnv")
        files=(
            "$path_prefix/common/Fallout New Vegas/Fallout_default.ini"
            "$path_prefix/compatdata/22380/pfx/drive_c/users/steamuser/Documents/My Games/FalloutNV/FalloutPrefs.ini"
            "$path_prefix/compatdata/22380/pfx/drive_c/users/steamuser/Documents/My Games/FalloutNV/Fallout.ini"
        )

        disable_mouse_accel=0

        ask_for_confirmation "Disable mouse acceleration?" && disable_mouse_accel=1

        for file in "${files[@]}"; do
            if [ ! -f "$file" ]; then
                yellow_message "Warning:" "'$file' does not exist."
                continue
            fi

            if [ "$disable_mouse_accel" -eq 1 ]; then
                if ! grep -Fq "fForegroundMouseAccelTop=0" "$file"; then
                    sed -i '/Controls/r /dev/stdin' "$file" <<-'EOF' \
                        && tweaks_applied=1
fForegroundMouseAccelTop=0
fForegroundMouseBase=0
fForegroundMouseMult=0
EOF
                else
                    tweaks_applied=1
                fi
            fi
        done
        ;;
    "me")
        files=(
            "$path_prefix/compatdata/17410/pfx/drive_c/users/steamuser/Documents/EA Games/Mirror's Edge/TdGame/Config/TdEngine.ini"
        )

        uncap_fps=0
        disable_bloom=0

        ask_for_confirmation "Uncap framerate?" && uncap_fps=1
        ask_for_confirmation "Disable bloom?" && disable_bloom=1

        for file in "${files[@]}"; do
            if [ ! -f "$file" ]; then
                yellow_message "Warning:" "'$file' does not exist."
                continue
            fi

            if [ "$uncap_fps" -eq 1 ]; then
                sed -i 's/SmoothFrameRate=True/SmoothFrameRate=False/g' "$file" \
                    && tweaks_applied=1
            fi

            if [ "$disable_bloom" -eq 1 ]; then
                sed -i \
                    -e 's/Bloom=True/Bloom=False/g' \
                    -e 's/QualityBloom=True/QualityBloom=False/g' "$file" \
                    && tweaks_applied=1
            fi
        done
        ;;
    "ja")
        dirs=(
            "$path_prefix/steamapps/common/Jedi Academy/GameData/base"
        )

        if ask_for_confirmation "Add custom configuration?"; then
            if [ -z "$display" ]; then
                read -er -p "Enter display width: " display_w
                read -er -p "Enter display height: " display_h
                read -er -p "Enter display refresh rate: " refresh_rate

                vars=(display_w display_h max_fps_target)

                for var in "${vars[@]}"; do
                    if [ -z "${!var}" ]; then
                        red_message "Error:" "$var is empty."
                        exit 1
                    fi
                done

                max_fps_target=$(awk "BEGIN {printf \"%.0f\", int(($refresh_rate - 5) / 10 + 0.5) * 10}")
            fi

            for dir in "${dirs[@]}"; do
                if [ -d "$dir" ]; then
                    cat <<-EOF | sed 's/^[[:space:]]*//' \
                        | tee "$dir/autoexec.cfg" \
                        && tweaks_applied=1
                        devmapall
                        set helpusobi 1
                        set sv_cheats 1
                        set r_mode "-1"
                        set r_customwidth "$display_w"
                        set r_customheight "$display_h"
                        set cg_fov "110"
                        com_maxfps "$max_fps_target"
EOF
                else
                    yellow_message "Warning:" "'$dir' does not exist."
                fi
            done
        fi
        ;;
    "tesiv")
        files=(
            "$path_prefix/common/Oblivion/Oblivion_default.ini"
            "$path_prefix/compatdata/22330/pfx/drive_c/users/steamuser/Documents/My Games/Oblivion/Oblivion.ini"
        )

        disable_intros=0
        enable_colorful_map=0

        ask_for_confirmation "Disable intro movies?" && disable_intros=1
        ask_for_confirmation "Enable colorful local map?" && enable_colorful_map=1

        for file in "${files[@]}"; do
            if [ ! -f "$file" ]; then
                yellow_message "Warning:" "'$file' does not exist."
                continue
            fi

            if [ "$disable_intros" -eq 1 ]; then
                sed -i \
                    -e 's/SIntroSequence=.*/SIntroSequence=/g' \
                    -e 's/SMainMenuMovieIntro=.*/SMainMenuMovieIntro=/g' "$file" \
                    && tweaks_applied=1
            fi

            if [ "$enable_colorful_map" -eq 1 ]; then
                sed -i 's/bLocalMapShader=1/bLocalMapShader=0/g' "$file" \
                    && tweaks_applied=1
            fi
        done
        ;;
    "tesv")
        files=(
            "$path_prefix/common/Skyrim Special Edition/Skyrim_Default.ini"
            "$path_prefix/common/Skyrim Special Edition/Skyrim/SkyrimPrefs.ini"
            "$path_prefix/compatdata/489830/pfx/drive_c/users/steamuser/Documents/My Games/Skyrim Special Edition/SkyrimPrefs.ini"
            "$path_prefix/compatdata/489830/pfx/drive_c/users/steamuser/Documents/My Games/Skyrim Special Edition/Skyrim.ini"
        )

        disable_dof=0
        disable_lens_flare=0

        ask_for_confirmation "Disable depth of field?" && disable_dof=1
        ask_for_confirmation "Disable lens flare?" && disable_lens_flare=1

        for file in "${files[@]}"; do
            if [ ! -f "$file" ]; then
                yellow_message "Warning:" "'$file' does not exist."
                continue
            fi

            if [ "$disable_dof" -eq 1 ]; then
                sed -i 's/bDoDepthOfField=1/bDoDepthOfField=0/g' "$file" \
                    && tweaks_applied=1
            fi

            if [ "$disable_lens_flare" -eq 1 ]; then
                sed -i 's/bLensFlare=1/bLensFlare=0/g' "$file" \
                    && tweaks_applied=1
            fi
        done
        ;;
    "tl")
        files=(
            "$path_prefix/compatdata/41500/pfx/drive_c/users/steamuser/AppData/Roaming/runic games/torchlight/settings.txt"
        )

        for file in "${files[@]}"; do
            if [ -f "$file" ]; then
                subs=()

                ask_for_confirmation "Enable console?" && subs+=('s/CONSOLE :0/CONSOLE :1/')
                ask_for_confirmation "Disable screen shake?" && subs+=('s/NO CAMERA SHAKE :0/NO CAMERA SHAKE :1/')

                if [ "${#subs[@]}" -gt 0 ]; then
                    apply_utf16_substitutions "$file" "${subs[@]}" \
                        && tweaks_applied=1
                fi
            else
                yellow_message "Warning:" "'$file' does not exist."
            fi
        done
        ;;
    *)
        red_message "Error:" "No game selected."
        exit 1
esac

if [ "$tweaks_applied" -eq 1 ]; then
    green_message "Success:" "Tweaks complete."
else
    yellow_message "Skipped:" "No tweaks were applied."
fi
