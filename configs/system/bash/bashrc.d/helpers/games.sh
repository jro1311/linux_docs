# shellcheck shell=bash
# shellcheck disable=SC2034

define_steam_prefix() {
    if command -v /usr/bin/steam >/dev/null 2>&1; then
        path_prefix="$HOME/.local/share/Steam"

    elif flatpak list --app --columns=app | grep -Fq "com.valvesoftware.Steam"; then
        path_prefix="$HOME/.var/app/com.valvesoftware.Steam/data/Steam"

    elif command -v /snap/bin/steam >/dev/null 2>&1; then
        path_prefix="$HOME/snap/steam/common/.steam/steam"
    else
        red_message "Not detected:" "Steam"
        return 1
    fi
}

tweak_fallout4() {
    local path_prefix="$1"
    local tweaks_applied_local=0
    local file
    local files=(
        "$path_prefix/steamapps/common/Fallout 4/Fallout4_Default.ini"
        "$path_prefix/steamapps/common/Fallout 4/Fallout4/Fallout4Prefs.ini"
        "$path_prefix/steamapps/compatdata/377160/pfx/drive_c/users/steamuser/My Documents/My Games/Fallout4/Fallout4Prefs.ini"
        "$path_prefix/steamapps/compatdata/377160/pfx/drive_c/users/steamuser/My Documents/My Games/Fallout4/Fallout4.ini"
    )

    local disable_dof=0
    local disable_mouse_accel=0

    ask_for_confirmation "Disable depth of field?" && disable_dof=1
    ask_for_confirmation "Disable mouse acceleration?" && disable_mouse_accel=1

    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            yellow_message "Warning:" "missing '$file'"
            continue
        fi

        if [ "$disable_dof" -eq 1 ]; then
            sed -i \
                -e 's/bDoDepthOfField=1/bDoDepthOfField=0/g' \
                -e 's/bScreenSpaceBokeh=1/bScreenSpaceBokeh=0/g' "$file" \
                && tweaks_applied_local=1
        fi

        if [ "$disable_mouse_accel" -eq 1 ]; then
            sed -i 's/bMouseAcceleration=1/bMouseAcceleration=0/g' "$file" \
                && tweaks_applied_local=1
        fi
    done

    if [ "$tweaks_applied_local" -eq 1 ]; then
        return 0
    else
        return 1
    fi
}

tweak_fallout_new_vegas() {
    local path_prefix="$1"
    local tweaks_applied_local=0
    local file
    local files=(
        "$path_prefix/steamapps/common/Fallout New Vegas/Fallout_default.ini"
        "$path_prefix/steamapps/compatdata/22380/pfx/drive_c/users/steamuser/Documents/My Games/FalloutNV/FalloutPrefs.ini"
        "$path_prefix/steamapps/compatdata/22380/pfx/drive_c/users/steamuser/Documents/My Games/FalloutNV/Fallout.ini"
    )

    local disable_mouse_accel=0

    ask_for_confirmation "Disable mouse acceleration?" && disable_mouse_accel=1

    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            yellow_message "Warning:" "missing '$file'"
            continue
        fi

        if [ "$disable_mouse_accel" -eq 1 ]; then
            if ! grep -Fq "fForegroundMouseAccelTop=0" "$file"; then
                sed -i '/Controls/r /dev/stdin' "$file" <<-'EOF' \
                    && tweaks_applied_local=1
fForegroundMouseAccelTop=0
fForegroundMouseBase=0
fForegroundMouseMult=0
EOF
            else
                tweaks_applied_local=1
            fi
        fi
    done

    if [ "$tweaks_applied_local" -eq 1 ]; then
        return 0
    else
        return 1
    fi
}

tweak_mirrors_edge() {
    local path_prefix="$1"
    local tweaks_applied_local=0
    local file
    local files=(
        "$path_prefix/steamapps/compatdata/17410/pfx/drive_c/users/steamuser/Documents/EA Games/Mirror's Edge/TdGame/Config/TdEngine.ini"
    )

    local uncap_fps=0
    local disable_bloom=0

    ask_for_confirmation "Uncap framerate?" && uncap_fps=1
    ask_for_confirmation "Disable bloom?" && disable_bloom=1

    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            yellow_message "Warning:" "missing '$file'"
            continue
        fi

        if [ "$uncap_fps" -eq 1 ]; then
            sed -i 's/SmoothFrameRate=True/SmoothFrameRate=False/g' "$file" \
                && tweaks_applied_local=1
        fi

        if [ "$disable_bloom" -eq 1 ]; then
            sed -i \
                -e 's/Bloom=True/Bloom=False/g' \
                -e 's/QualityBloom=True/QualityBloom=False/g' "$file" \
                && tweaks_applied_local=1
        fi
    done

    if [ "$tweaks_applied_local" -eq 1 ]; then
        return 0
    else
        return 1
    fi
}

tweak_jedi_academy() {
    local path_prefix="$1"
    local tweaks_applied_local=0
    local dir
    local dirs=(
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
                    && tweaks_applied_local=1
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
                yellow_message "Warning:" "missing '$dir'"
            fi
        done
    fi

    if [ "$tweaks_applied_local" -eq 1 ]; then
        return 0
    else
        return 1
    fi
}

tweak_oblivion() {
    local path_prefix="$1"
    local tweaks_applied_local=0
    local file
    local files=(
        "$path_prefix/steamapps/common/Oblivion/Oblivion_default.ini"
        "$path_prefix/steamapps/compatdata/22330/pfx/drive_c/users/steamuser/Documents/My Games/Oblivion/Oblivion.ini"
    )

    local disable_intros=0
    local enable_colorful_map=0

    ask_for_confirmation "Disable intro movies?" && disable_intros=1
    ask_for_confirmation "Enable colorful local map?" && enable_colorful_map=1

    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            yellow_message "Warning:" "missing '$file'"
            continue
        fi

        if [ "$disable_intros" -eq 1 ]; then
            sed -i \
                -e 's/SIntroSequence=.*/SIntroSequence=/g' \
                -e 's/SMainMenuMovieIntro=.*/SMainMenuMovieIntro=/g' "$file" \
                && tweaks_applied_local=1
        fi

        if [ "$enable_colorful_map" -eq 1 ]; then
            sed -i 's/bLocalMapShader=1/bLocalMapShader=0/g' "$file" \
                && tweaks_applied_local=1
        fi
    done

    if [ "$tweaks_applied_local" -eq 1 ]; then
        return 0
    else
        return 1
    fi
}

tweak_skyrim() {
    local path_prefix="$1"
    local tweaks_applied_local=0
    local file
    local files=(
        "$path_prefix/steamapps/common/Skyrim Special Edition/Skyrim_Default.ini"
        "$path_prefix/steamapps/common/Skyrim Special Edition/Skyrim/SkyrimPrefs.ini"
        "$path_prefix/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/Documents/My Games/Skyrim Special Edition/SkyrimPrefs.ini"
        "$path_prefix/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/Documents/My Games/Skyrim Special Edition/Skyrim.ini"
    )

    local disable_dof=0
    local disable_lens_flare=0

    ask_for_confirmation "Disable depth of field?" && disable_dof=1
    ask_for_confirmation "Disable lens flare?" && disable_lens_flare=1

    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            yellow_message "Warning:" "missing '$file'"
            continue
        fi

        if [ "$disable_dof" -eq 1 ]; then
            sed -i 's/bDoDepthOfField=1/bDoDepthOfField=0/g' "$file" \
                && tweaks_applied_local=1
        fi

        if [ "$disable_lens_flare" -eq 1 ]; then
            sed -i 's/bLensFlare=1/bLensFlare=0/g' "$file" \
                && tweaks_applied_local=1
        fi
    done

    if [ "$tweaks_applied_local" -eq 1 ]; then
        return 0
    else
        return 1
    fi
}

tweak_torchlight() {
    local path_prefix="$1"
    local tweaks_applied_local=0
    local file
    local files=(
        "$path_prefix/steamapps/compatdata/41500/pfx/drive_c/users/steamuser/AppData/Roaming/runic games/torchlight/settings.txt"
    )

    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            subs=()

            ask_for_confirmation "Enable console?" && subs+=('s/CONSOLE :0/CONSOLE :1/')
            ask_for_confirmation "Disable screen shake?" && subs+=('s/NO CAMERA SHAKE :0/NO CAMERA SHAKE :1/')

            if [ "${#subs[@]}" -gt 0 ]; then
                apply_utf16_substitutions "$file" "${subs[@]}" \
                    && tweaks_applied_local=1
            fi
        else
            yellow_message "Warning:" "missing '$file'"
        fi
    done

    if [ "$tweaks_applied_local" -eq 1 ]; then
        return 0
    else
        return 1
    fi
}
