# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

configure_corectrl() {
    local exec
    exec="corectrl"

    detect_system

    sudo mkdir -p /etc/polkit-1/rules.d
    sudo tee /etc/polkit-1/rules.d/90-corectrl.rules >/dev/null <<-EOF
polkit.addRule(function(action, subject) {
    if ((action.id == 'org.corectrl.helper.init' ||
         action.id == 'org.corectrl.helperkiller.init') &&
        subject.local == true &&
        subject.active == true &&
        subject.isInGroup("$(id -gn)")) {
            return polkit.Result.YES;
    }
});
EOF

    if [ "$amd_gpu_detected" -eq 1 ]; then
        add_kernel_parameter "amdgpu.ppfeaturemask=0xffffffff"
    fi

    create_autostart_entry "corectrl" "corectrl"
}

configure_lact() {
    detect_system
    enable_service "lactd"

    if [ "$amd_gpu_detected" -eq 1 ]; then
        add_kernel_parameter "amdgpu.ppfeaturemask=0xffffffff"
    fi
}

configure_mangohud() {
    local overwrite="${1:-0}"

    if [ "$overwrite" -eq 1 ] \
        || [ ! -f "$HOME/.config/MangoHud/MangoHud.conf" ]; then
        mkdir -p "$HOME/.config/MangoHud"
        cp "$path_prefix/applications/MangoHud.conf" "$HOME/.config/MangoHud/"

        detect_system

        if [ -z "$refresh_rate" ]; then
            refresh_rate=$(input_positive_integer "display refresh rate")
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

        mkdir -p "$HOME/Documents/mangohud/logs"
        if ! grep -Fq "output_folder" "$HOME/.config/MangoHud/MangoHud.conf"; then
            echo "output_folder=$HOME/Documents/mangohud/logs" >> "$HOME/.config/MangoHud/MangoHud.conf"
        fi
    fi
}
