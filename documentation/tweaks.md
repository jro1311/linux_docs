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
    - Dynamic Wallpaper
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

## ProtonPlus
- Download and install latest Proton GE
    
## Steam
- Settings>Compatibility
    - Default compatibility tool: `Proton Experimental`
