# General

## Removed packages from original setup

- bitwarden
- discord
- furmark
- heroic games launcher
- lact
- mangohud
- prismlauncher
- protontricks
- rocm-smi
- spotify
- steam

## Removed lines

- Makes directory(s)
- mkdir -pv $HOME/.config/MangoHud
- mkdir -pv $HOME/Documents/MangoHud/logs

- Grants flatpaks read-only access to MangoHud's config file
- flatpak override --user --filesystem=xdg-config/MangoHud:ro com.geeks3d.furmark 
- flatpak override --user --filesystem=xdg-config/MangoHud:ro com.heroicgameslauncher.hgl
- flatpak override --user --filesystem=xdg-config/MangoHud:ro org.prismlauncher.PrismLauncher

- Checks for AMD GPU
    - if echo "$gpu_info" | grep -i "amd" &> /dev/null; then
        - echo "AMD GPU detected"
        - Installs package(s)
        - sudo nala install -y rocm-smi
        
        - Adds kernel argument(s)
        - sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ amdgpu.ppfeaturemask=0xffffffff "/' /etc/default/grub
    - else
        - echo "No AMD GPU detected"
    - fi

- Uninstalls package(s)
- sudo dnf remove -y gnome-tour
- sudo zypper rm --clean-deps -y gnome-tour

- Adds package(s) to autostart
- cp -v /usr/share/applications/transmission*.desktop $HOME/.config/autostart/

# Zach

## Removed packages from original setup

- bitwarden
- heroic games launcher
- spotify

## Changed lines

- Copies config(s)
- cp -v $HOME/Documents/linux_docs/configs/packages/MangoHud_zach.conf $HOME/.config/MangoHud/
- mv -v $HOME/.config/MangoHud/MangoHud_zach.conf $HOME/.config/MangoHud/MangoHud.conf

## Removed lines

- Grants flatpaks read-only access to MangoHud's config file
- flatpak override --user --filesystem=xdg-config/MangoHud:ro com.heroicgameslauncher.hgl

- Uninstalls package(s)
- sudo dnf remove -y gnome-tour
- sudo zypper rm --clean-deps -y gnome-tour

- Adds package(s) to autostart
- cp -v /usr/share/applications/transmission*.desktop $HOME/.config/autostart/

