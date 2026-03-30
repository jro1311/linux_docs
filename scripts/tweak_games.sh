#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Sources all .sh files in $HOME/Documents/linux_docs/configs/system/bash/bashrc.d
shopt -s globstar nullglob

# shellcheck source=/dev/null
for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f $rc ]] && source "$rc"
done
unset rc

shopt -u globstar nullglob
shopt -s nullglob

# Define path prefix
if command -v snap >/dev/null 2>&1 && snap list | grep -Fiq "steam"; then
    path_prefix="$HOME/snap/steam/common/.steam/steam/steamapps"

elif command -v steam >/dev/null 2>&1; then
    path_prefix="$HOME/.local/share/Steam/steamapps"

elif command -v flatpak >/dev/null 2>&1 && flatpak list --app --columns=app | grep -Fiq "com.valvesoftware.Steam"; then
    path_prefix="$HOME/.var/app/com.valvesoftware.Steam/data/Steam/steamapps"

else
    red_message "Steam not detected."
    exit 1
fi

ask_for_game() {
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
[tesiv] The Elder Scrolls IV: Oblivion"

ask_for_game "Enter game"

case "$game" in
    "f4")
        dirs=(
            "$path_prefix/common/Fallout 4/Fallout4/Fallout4Prefs.ini"
            "$path_prefix/compatdata/377160/pfx/drive_c/users/steamuser/My Documents/My Games/Fallout4/Fallout4Prefs.ini"
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
            for dir in "${dirs[@]}"; do
                if [ -f "$dir" ]; then
                    cat <<-'EOF' | sed 's/^[[:space:]]*//' | tee "$path_prefix/steamapps/common/Jedi Academy/GameData/base/autoexec.cfg"
                    devmapall
                    set helpusobi 1
                    set sv_cheats 1
                    set r_mode "-1"
                    set r_customwidth "2560"
                    set r_customheight "1440"
                    set cg_fov "110"
                    com_maxfps 160
EOF
                else
                    yellow_message "'$dir' does not exist."
                fi
            done
        fi
        ;;
    "tesiv")
        dirs=(
            "$path_prefix/compatdata/22330/pfx/drive_c/users/steamuser/Documents/My Games/Oblivion/Oblivion.ini"
        )

        if ask_for_confirmation "Disable intro movies?"; then
            for dir in "${dirs[@]}"; do
                if [ -f "$dir" ]; then
                    sed -i 's/SIntroSequence=.*/SIntroSequence=/g' "$dir"
                else
                    yellow_message "'$dir' does not exist."
                fi
            done
        fi
        ;;
esac

green_message "Tweaks complete."
