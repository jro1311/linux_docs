# General

## Removed packages from original setup

- bitwarden
- vesktop
- furmark
- gnome-tour
- heroicgameslauncher
- lact
- mangohud
- prismlauncher
- protontricks
- rocm-smi
- spotify
- steam

## Removed lines

- mkdir -pv $HOME/.config/MangoHud
- mkdir -pv "$HOME/Documents/mangohud/logs"

- flatpak override --user --filesystem=xdg-config/MangoHud:ro com.geeks3d.furmark 
- flatpak override --user --filesystem=xdg-config/MangoHud:ro com.heroicgameslauncher.hgl
- flatpak override --user --filesystem=xdg-config/MangoHud:ro org.prismlauncher.PrismLauncher

- if echo "$gpu_info" | grep -i "amd" &> /dev/null; then
    - echo "AMD GPU detected"  
    - sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ amdgpu.ppfeaturemask=0xffffffff "/' /etc/default/grub
- else
    - echo "No AMD GPU detected"
- fi

- chmod +x $HOME/Documents/linux_docs/scripts/packages/terminal/proton_ge_install.sh
- $HOME/Documents/linux_docs/scripts/packages/terminal/proton_ge_install.sh

- cp -v /usr/share/applications/transmission*.desktop $HOME/.config/autostart/
