# Tweaks
## linux_docs
1. Remove old linux_docs folder, then change directory, then clone git repo

    ```bash
    local_dir="$HOME/Documents/linux_docs"
    repo_url="https://github.com/jro1311/linux_docs.git"
    
    rm -rf "$local_dir"

    if ! command -v git >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y git
    fi

    git clone "$repo_url" "$local_dir"
    ```
    
2. Change directory, make all scripts executable, then run `tweaks.sh`

    ```bash
    dir="$HOME/Documents/linux_docs/scripts"
    
    chmod +x "$dir/chmod_scripts.sh"
    "$dir/chmod_scripts.sh" && "$dir/tweaks.sh"
    ```
    
## Snapshot Retention (timeshift/snapper/btrfs-assistant)
### Minimum (safe baseline)
- Weekly: `2`
- Daily: `3`

### Recommended (optimal protection)
- Weekly: `3`
- Daily: `7`
    
## Update Manager
- View > Linux Kernels
    - Remove old kernels
- Preferences > Automation
    - Package Updates: `Enabled`
    - Other Updates: `Enabled`
    - Automatic Maintenance: `Enabled`

## Cinnamon
- **Extensions**
    - Blur Cinnamon
- **Terminal**
    - Text and background color: `Solarized dark`
    - Palette: `XTerm`
- **System Settings**
    - Preferences > General
        - Check `Disable compositing for full-screen windows`
    - Administration > Firewall
        - Select `Home` profile
        - Enable
    - Night Light
        - Enable
        
## HP Printer Setup
1. Install packages `hplip` and `hplip-gui`
2. Run `hp-setup` in terminal or `HP Setup` in GUI
3. Show Advanced Options > Manual Discovery
    - Add the local IP address of the printer (e.g., 192.168.0.xx)

## Brave
### brave://flags
- #middle-button-autoscroll = `Enabled`

### Settings
- Trackers & ads blocking: `Aggressive`
- Upgrade connections to HTTPS: `Standard`
- Block cookies: `Allow all cookies`

## Firefox/LibreWolf
### Settings
- Privacy & Security
    - Select `Enable HTTPS-Only Mode in all windows`
- LibreWolf
    - Uncheck `Enable ResistFingerprinting`
        - Uncheck `Enable letterboxing`
        - Uncheck `Silently block canvas access requests`
    - Check `Enable WebGL`

## Text Editor
- Change theme to `Cobalt`, `Solarized Dark`, or `Oblivion`

```bash
# Configure editors to use tabs instead of spaces
sed -i 's/"tabstospaces": true/"tabstospaces": false/' "$HOME/.config/micro/settings.json"
sed -i 's/set tabstospaces/#set tabstospaces/' "$HOME/.config/nano/nanorc"
sudo sed -i 's/set tabstospaces/#set tabstospaces/' /etc/nanorc
```
    
## CoreCtrl
- Performance Level: `Manual`
- Power Profile Mode: `3D_FULL_SCREEN`
- **Cool and Quiet**
    - Power Limit: `75 W`
    - Max GPU Clock: `Default`
    - GPU Voltage Offset: `-75 mV`
- **Performance**
    - Power Limit: `100 W`
    - Max GPU Clock: `Default`
    - GPU Voltage Offset: `-75 mV`
        
## Prism Launcher
- **Settings > General**
    - Enable MangoHud
- **Settings > Java**
    - Minimum Memory Usage (-Xms)
        - 2048 MiB
    - Maximum Memory Usage (-Xmx)
        - 4096 MiB
        - **Modding Levels**
            - Light
                - 4096 MiB
            - Medium
                - 6144 MiB
            - Heavy
                - 8192 MiB
- **Set up Instance**
    - Add Instance
    - Edit > Version > Install Loader
        - Fabric
    - Edit > Mods > Download Mods
    - Edit > Resource Packs > Download Packs
    - Edit > Shader Packs > Download Packs

### BTRFS: Disable COW for Minecraft Worlds

```bash
chattr -R +C "$HOME"/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/instances/*/minecraft/saves
```

## ProtonPlus
- Download and install latest Proton GE
    
## Steam
- Settings>Compatibility
    - Default compatibility tool: `Proton Experimental`
