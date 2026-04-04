#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

display_cmd="unknown"
display="unknown"
refresh_rate="unknown"
max_fps_target="unknown"

# Sources all .sh files in $HOME/Documents/linux_docs/configs/system/bash/bashrc.d
shopt -s globstar nullglob

# shellcheck source=/dev/null
for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f "$rc" ]] && source "$rc"
done
unset rc

shopt -u globstar nullglob
shopt -s nullglob

# Define path prefix
if command -v /usr/bin/steam >/dev/null 2>&1; then
    path_prefix="$HOME/.local/share/Steam/steamapps"

elif command -v flatpak >/dev/null 2>&1 && flatpak list --app --columns=app | grep -Fiq "com.valvesoftware.Steam"; then
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

game_selection() {
    local prompt="$1"
    local answer
    game="unknown"

    read -r -p "$prompt: " answer
    answer="${answer:-y}"

    case "$answer" in
        "f4") game="f4" ;;
        "fnv") game="fnv";;
        "me") game="me" ;;
        "ja") game="ja" ;;
        "tesiv") game="tesiv" ;;
        "tesv") game="tesv" ;;
        *)
            red_message "No game selected."
            exit 1
    esac
}

green_message "Supported Games:"
echo "[f4] Fallout 4
[fnv] Fallout New Vegas
[me] Mirror's Edge
[ja] Star Wars Jedi Knight: Jedi Academy
[tesiv] The Elder Scrolls IV: Oblivion
[tesv] The Elder Scrolls V: Skyrim"

game_selection "Enter game"

case "$game" in
    "f4")
        dirs=(
            "$path_prefix/common/Fallout 4/Fallout4_Default.ini"
            "$path_prefix/common/Fallout 4/Fallout4/Fallout4Prefs.ini"
            "$path_prefix/compatdata/377160/pfx/drive_c/users/steamuser/My Documents/My Games/Fallout4/Fallout4Prefs.ini"
            "$path_prefix/compatdata/377160/pfx/drive_c/users/steamuser/My Documents/My Games/Fallout4/Fallout4.ini"
        )

        if ask_for_confirmation "Disable depth of field?"; then
            for dir in "${dirs[@]}"; do
                if [ -f "$dir" ]; then
                    sed -i 's/bDoDepthOfField=1/bDoDepthOfField=0/g' "$dir"
                    sed -i 's/bScreenSpaceBokeh=1/bScreenSpaceBokeh=0/g' "$dir"
                else
                    yellow_message "'$dir' does not exist."
                fi
            done
        fi

        if ask_for_confirmation "Disable mouse acceleration?"; then
            for dir in "${dirs[@]}"; do
                if [ -f "$dir" ]; then
                    sed -i 's/bMouseAcceleration=1/bMouseAcceleration=0/g' "$dir"
                else
                    yellow_message "'$dir' does not exist."
                fi
            done
        fi
        ;;
    "fnv")
        dirs=(
            "$path_prefix/common/Fallout New Vegas/Fallout_default.ini"
            "$path_prefix/compatdata/22380/pfx/drive_c/users/steamuser/Documents/My Games/FalloutNV/FalloutPrefs.ini"
            "$path_prefix/compatdata/22380/pfx/drive_c/users/steamuser/Documents/My Games/FalloutNV/Fallout.ini"
        )

        if ask_for_confirmation "Disable mouse acceleration?"; then
            for dir in "${dirs[@]}"; do
                if [ ! -f "$dir" ]; then
                    yellow_message "'$dir' does not exist."

                elif grep -Fq "fForegroundMouseAccelTop=0" "$dir"; then
                    yellow_message "'$dir' already has settings applied."

                else
                    sed -i '/Controls/r /dev/stdin' "$dir" <<'EOF'
fForegroundMouseAccelTop=0
fForegroundMouseBase=0
fForegroundMouseMult=0
EOF
                fi
            done
        fi
        ;;
    "me")
        dirs=(
            "$path_prefix/compatdata/17410/pfx/drive_c/users/steamuser/Documents/EA Games/Mirror's Edge/TdGame/Config/TdEngine.ini"
        )

        if ask_for_confirmation "Uncap framerate?"; then
            for dir in "${dirs[@]}"; do
                if [ -f "$dir" ]; then
                    sed -i 's/SmoothFrameRate=True/SmoothFrameRate=False/g' "$dir"
                else
                    yellow_message "'$dir' does not exist."
                fi
            done
        fi

        if ask_for_confirmation "Disable bloom?"; then
            for dir in "${dirs[@]}"; do
                if [ -f "$dir" ]; then
                    sed -i 's/Bloom=True/Bloom=False/g' "$dir"
                    sed -i 's/QualityBloom=True/QualityBloom=False/g' "$dir"
                else
                    yellow_message "'$dir' does not exist."
                fi
            done
        fi
        ;;
    "ja")
        dirs=(
            "$path_prefix/steamapps/common/Jedi Academy/GameData/base/autoexec.cfg"
        )

        if ask_for_confirmation "Add custom configuration?"; then
            if [ "$display_cmd" = "unknown" ]; then
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
                if [ -f "$dir" ]; then
                    cat <<-EOF | sed 's/^[[:space:]]*//' | tee "$path_prefix/steamapps/common/Jedi Academy/GameData/base/autoexec.cfg"
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
                    yellow_message "'$dir' does not exist."
                fi
            done
        fi
        ;;
    "tesiv")
        dirs=(
            "$path_prefix/common/Oblivion/Oblivion_default.ini"
            "$path_prefix/compatdata/22330/pfx/drive_c/users/steamuser/Documents/My Games/Oblivion/Oblivion.ini"
        )

        if ask_for_confirmation "Disable intro movies?"; then
            for dir in "${dirs[@]}"; do
                if [ -f "$dir" ]; then
                    sed -i 's/SIntroSequence=.*/SIntroSequence=/g' "$dir"
                    sed -i 's/SMainMenuMovieIntro=.*/SMainMenuMovieIntro=/g' "$dir"
                else
                    yellow_message "'$dir' does not exist."
                fi
            done
        fi

        if ask_for_confirmation "Enable colorful local map?"; then
            for dir in "${dirs[@]}"; do
                if [ -f "$dir" ]; then
                    sed -i 's/bLocalMapShader=1/bLocalMapShader=0/g' "$dir"
                else
                    yellow_message "'$dir' does not exist."
                fi
            done
        fi
        ;;
    "tesv")
        dirs=(
            "$path_prefix/common/Skyrim Special Edition/Skyrim_Default.ini"
            "$path_prefix/common/Skyrim Special Edition/Skyrim/SkyrimPrefs.ini"
            "$path_prefix/compatdata/489830/pfx/drive_c/users/steamuser/Documents/My Games/Skyrim Special Edition/SkyrimPrefs.ini"
            "$path_prefix/compatdata/489830/pfx/drive_c/users/steamuser/Documents/My Games/Skyrim Special Edition/Skyrim.ini"
        )

        if ask_for_confirmation "Disable depth of field?"; then
            for dir in "${dirs[@]}"; do
                if [ -f "$dir" ]; then
                    sed -i 's/bDoDepthOfField=1/bDoDepthOfField=0/g' "$dir"
                else
                    yellow_message "'$dir' does not exist."
                fi
            done
        fi

        if ask_for_confirmation "Disable lens flare?"; then
            for dir in "${dirs[@]}"; do
                if [ -f "$dir" ]; then
                    sed -i 's/bLensFlare=1/bLensFlare=0/g' "$dir"
                else
                    yellow_message "'$dir' does not exist."
                fi
            done
        fi
        ;;
esac

green_message "Tweaks complete."
