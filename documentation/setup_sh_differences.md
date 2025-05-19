# General

## Removed packages from original setup

- bitwarden
- discord
- furmark
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
- mkdir -pv $HOME/Documents/MangoHud/logs

- flatpak override --user --filesystem=xdg-config/MangoHud:ro com.geeks3d.furmark 
- flatpak override --user --filesystem=xdg-config/MangoHud:ro com.heroicgameslauncher.hgl
- flatpak override --user --filesystem=xdg-config/MangoHud:ro org.prismlauncher.PrismLauncher

- if echo "$gpu_info" | grep -i "amd" &> /dev/null; then
    - echo "AMD GPU detected"
    - sudo nala install -y rocm-smi
        
    - sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ amdgpu.ppfeaturemask=0xffffffff "/' /etc/default/grub
- else
    - echo "No AMD GPU detected"
- fi

- chmod +x $HOME/Documents/linux_docs/scripts/packages/terminal/proton_ge_install.sh
- $HOME/Documents/linux_docs/scripts/packages/terminal/proton_ge_install.sh

- sudo dnf remove -y gnome-tour
- sudo zypper rm --clean-deps -y gnome-tour

- cp -v /usr/share/applications/transmission*.desktop $HOME/.config/autostart/
