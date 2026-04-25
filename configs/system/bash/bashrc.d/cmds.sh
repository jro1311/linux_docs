#!/usr/bin/env bash
# shellcheck shell=bash

if ! command -v protontricks >/dev/null 2>&1 \
    && flatpak list --columns=app 2>/dev/null | grep -Fq "com.github.Matoking.protontricks"; then

    protontricks() {
        flatpak run com.github.Matoking.protontricks "$@"
    }

    protontricks_launch() {
        flatpak run --command=protontricks-launch com.github.Matoking.protontricks "$@"
    }

fi

clean_git() {
    local dir="${1:-$LD_ROOT}"
    git -C "$dir" gc --aggressive --prune=now
}

check_weather() {
    "$LD_SCR/check_weather.sh" "$@"
}

chmod_scripts() {
    [ ! -x "$LD_SCR/chmod_scripts.sh" ] && chmod +x "$LD_SCR/chmod_scripts.sh"
    "$LD_SCR/chmod_scripts.sh" "$@"
}

create_swapfile() {
    "$LD_SCR/create_swapfile.sh" "$@"
}

dos2unix_converter() {
    "$LD_SCR/dos2unix_converter.sh" "$@"
}

export_smart_info() {
    "$LD_SCR/export_smart_info.sh" "$@"
}

find_text() {
    "$LD_SCR/find_text.sh" "$@"
}

gaming_stack() {
    "$LD_SCR/gaming_stack.sh" "$@"
}

generate_dnd_character() {
    "$LD_SCR/generate_dnd_character.sh" "$@"
}

git_clone_repo() {
    "$LD_SCR/git_clone_repo.sh" "$@"
}

git_push_repo() {
    "$LD_SCR/git_push_repo.sh" "$@"
}

git_sync_repo() {
    "$LD_SCR/git_sync_repo.sh" "$@"
}

remove_snap() {
    "$LD_SCR/remove_snap.sh" "$@"
}

remove_swapfile() {
    "$LD_SCR/remove_swapfile.sh" "$@"
}

replace_text() {
    "$LD_SCR/replace_text.sh" "$@"
}

setup_system() {
    "$LD_SCR/setup_system.sh" "$@"
}

shellcheck_all() {
    "$LD_SCR/shellcheck_all.sh" "$@"
}

snake_case_converter() {
    "$LD_SCR/snake_case_converter.sh" "$@"
}

sync_backup_drives() {
    "$LD_SCR/sync_backup_drives.sh" "$@"
}

sync_bashrc_configs() {
    "$LD_SCR/sync_bashrc_configs.sh" "$@"
}

sync_directory() {
    "$LD_SCR/sync_directory.sh" "$@"
}

copy_package_configs() {
    "$LD_SCR/copy_package_configs.sh" "$@"
}

tab_space_converter() {
    "$LD_SCR/tab_space_converter.sh" "$@"
}

tweak_games() {
    "$LD_SCR/tweak_games.sh" "$@"
}

update_readme() {
    "$LD_SCR/update_readme.sh" "$@"
}
