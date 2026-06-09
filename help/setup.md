# Setup Guide
## Initial Setup
1. Install and set up `timeshift`, `snapper`, or `btrfs-assistant`, then create a manual snapshot
2. Add mount options to runtime and `/etc/fstab`
    - **universal**
        - `noatime`
        - `nofail` (for secondary drives)
        - `noauto` (for secondary drives) (optional)
    - **btrfs**
        - `compress=zstd:1`
        - `autodefrag` (for HDDs)
    - **f2fs**
        - `compress_algorithm=zstd:1`
        
    ```bash
    sudo mount -o remount,mount_options /
    sudo "$EDITOR" /etc/fstab
    ```
        
3. Copy `linux_docs` folder from the USB drive to `"$HOME/Documents"`, or clone git repository

    ```bash
    # Option 1 (Local)
    usb_dir=$(find /mnt /media /run/media -maxdepth 3 -type d -name linux_docs -print -quit 2>/dev/null)
    local_dir="$HOME/Documents/linux_docs"
    
    mkdir -p "$HOME/Documents"

    if [ -z "$usb_dir" ]; then
        echo "Error: 'linux_docs' not found on any mounted drive."
    else
        rm -rf "$local_dir"
        cp -rv "$usb_dir" "$local_dir"
    fi

    # Option 2 (Git)
    repo_url="https://github.com/jro1311/linux_docs.git"
    local_dir="$HOME/Documents/linux_docs"
    
    mkdir -p "$HOME/Documents"
    rm -rf "$local_dir"
    git clone "$repo_url" "$local_dir"
    ```

4. In the `scripts` directory, make `chmod_scripts.sh` executable and run it in the terminal, then run `setup_system.sh`, then reboot

    ```bash
    cd "$HOME/Documents/linux_docs/scripts"
    chmod +x ./chmod_scripts.sh
    ./chmod_scripts.sh
    ./setup_system.sh
    ```

5. Create another manual snapshot of the current working system, then delete previous snapshot(s)

## Snapshot Retention (timeshift/snapper/btrfs-assistant)
### Minimal (safe baseline)
- Weekly: `2`
- Daily: `3`

### Recommended (best balance)
- Weekly: `3`
- Daily: `7`

### Extended (ideal for servers)
- Monthly: `3`
- Weekly: `5`
- Daily: `7`

## Linux Mint Update Manager
### View
- **Linux Kernels**
    - Remove old kernels
    - Install newest kernel
    
### Preferences
- **Options**
    - Auto-refresh
        - First, refresh the list of updates after: `5 minutes`
            - For very weak systems, set to `10 minutes`
        - Then, refresh the list of updates after: `4 hours`
- **Automation**
    - Package Updates: `Enabled`
    - Other Updates: `Enabled`
    - Automatic Maintenance: `Enabled`
    
## Text Editors
### GNOME Text Editor
- Settings > Preferences
    - Theme: `Cobalt`
    - Display Line Numbers: `Enabled`
    - Highlight Current Line: `Enabled`
    - Check Spelling: `Enabled`
    - Wrap Lines Automatically (Alt +W): `Enabled`
    - Auto indentation: `Enabled`
    - Character: `Space`
    - Spaces Per Tab: `4`
    - Spaces Per Indent: `4`
    - Discover Document Settings: `Enabled`
    
### Kate/Kwrite
- Settings > Configure Kate/Kwrite
    - **Color Themes**
        - Select theme: `Dracula`

### Xed
- Edit > Preferences
    - **Editor**
        - Display line numbers: `Enabled`
        - Highlight the current line: `Enabled`
        - Highlight matching brackets: `Enabled`
        - Tab width: `4`
        - Use spaces instead of tabs: `Enabled`
        - Automatic indentation: `Enabled`
        - Word wrap: `Enabled`
        - Allow mouse wheel scrolling to change tabs: `Enabled`
        - Auto close: `Enabled`
    - **Theme**
        - Dark theme: `Enabled`
        - Style scheme: `Cobalt`
    - **Plugins**
        - Bracket Completion: `Enabled`
        - Modelines: `Enabled`
        - Save Without Trailing Spaces: `Enabled`
        - Spell Checker: `Enabled`
        - Word Completion: `Enabled`

## Desktops
### Cinnamon
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

### GNOME
- **Extensions**
    - ArcMenu - arcmenu@arcmenu.com
    - Bluetooth battery indicator - bluetooth-battery@michaelw.github.com
    - Blur my Shell - blur-my-shell@aunetx
    - Color Picker - color-picker@tuberry
    - Dash to Panel - dash-to-panel@jderose9.github.com
    - Gtk4 Desktop Icons NG (DING) - gtk4-ding@smedius.gitlab.com
    - Legacy (GTK3) Theme Scheme Auto Switcher - legacyschemeautoswitcher@joshimukul29.gmail.com
    - No overview at start-up - no-overview@fthx
    - Vitals - Vitals@CoreCoding.com
    - Weather O'Clock - weatheroclock@CleoMenezesJr.github.io

### KDE Plasma
- **System Settings**
    - Keyboard > Shortcuts
        - Command:  `systemctl --user restart plasma-plasmashell`
        - Shortcut: `Ctrl+Alt+Esc`
    - Software Update
        - Update software: `Automatically`
        - Update frequency: `Weekly`
        - Apply system updates: `After rebooting`
- **Panel**
    - Add pager to panel and move to preferred location
        - Right click > Add Virtual Desktop
        - Right click > Configure pager
            - Check `Show application icons on window outlines`
            - Text display: `No text`
        - Right click > Configure Virtual Desktops
            - Rows: `1`
            - Check `Show animation when switching: Slide`
            - Check `Show on-screen display when switching: 500 ms`
            - Check `Show desktop layout indicators`
            - Edit names (e.g., Admin, Web, Game, Misc)
        - Switch between virtual desktops using scroll wheel while hovering over them

### Xfce
- **Settings**
    - Personal > Appearance
        - Style: `Greybird` or `Greybird-Dark`
        - Icons: `Elementary Xfce` or `Elementary Xfce Dark`
        - Fonts: `Noto Sans Regular`
    - Hardware > Keyboard > Application Shortcuts
        - Command:  `xfce4-popup-whiskermenu`
        - Shortcut: `Super L` (Super/Meta/Windows Key)
- **Whisker Menu**
    - Right-click Panel > Panel Preferences > Items > Add Whisker Menu

## HP Printer Setup
1. Install packages `hplip` and `hplip-gui`
2. Run `hp-setup` in terminal or `HP Setup` in GUI
3. Show Advanced Options > Manual Discovery
    - Add the local IP address of the printer (e.g., 192.168.0.xx)

## LibreOffice
- View > User Interface
    - Select `Tabbed`

## Firefox
### Settings
- **Privacy & Security**
    - Tracking Protection: `Strict`
        - Check: `Fix major site issues`
        - Check: `Fix minor site issues`
    - Select: `Enable HTTPS-Only Mode in all windows` 
    
### Extensions
- Dark Reader
- uBlock Origin
- Canvas Blocker
- Bitwarden
- SponsorBlock
- Return YouTube Dislike
- Chrome Mask
- Feeder
- Todoist
    
## Brave
### brave://flags
- #middle-button-autoscroll = `Enabled`

### Settings
- Trackers & ads blocking: `Aggressive`
- Upgrade connections to HTTPS: `Standard`
- Block cookies: `Allow all cookies`

### Extensions
- Dark Reader
- Bitwarden
- SponsorBlock
- Return YouTube Dislike
- Feeder
- Todoist
    
## GPU Profiles
### RX 6650 XT
- Performance Level: `Manual`
- Power Profile Mode: `COMPUTE`
- **Cool and Quiet**
    - Power Limit: `134 W`
    - Max GPU Clock: `2500 MHz`
    - GPU Voltage Offset: `-100 mV`
- **Performance**
    - Power Limit: `157 W`
    - Max GPU Clock: `2700 MHz`
    - GPU Voltage Offset: `-80 mV`

### RX 580
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
    
## ProtonPlus
- Tools > Proton-GE
    - Download: `Proton-GE Latest`
    
## Steam
### Settings
- **Compatibility**
    - Default compatibility tool: `Proton Experimental`
- **Downloads**
    - Disable: `Shader pre-caching`
- **In Game**
    - Disable: `Steam Overlay while in-game`

### Library
- Install: `Steamworks Common Redistributables`
    
## Prism Launcher
### Settings
- **General**
    - Check: `Enable MangoHud`
- **Java**
    - **Minimum Memory Usage (-Xms)**
        - <=4 GiB System RAM
            - 512 MiB
        - 6 GiB System RAM
            - 1024 MiB
        - \>=8 GiB System RAM
            - 2048 MiB
    - **Maximum Memory Usage (-Xmx)**
        - <=4 GiB System RAM
            - 1024 MiB
        - 6 GiB System RAM
            - 2048 MiB
        - \>=8 GiB System RAM
            - 4096 MiB
        - **Modding Levels**
            - Light
                - 4096 MiB
            - Medium
                - 6144 MiB
            - Heavy
                - 8192 MiB
                
### Instance Setup
- Add Instance > Custom
    - Version: Newest release
    - Mod Loader: `Fabric`
- Edit > Mods > Download Mods
    - Cloth Config v26\.1
    - Fabric API
    - FallingTree
    - Iris
    - Journeymap
    - Mod Menu
    - Placeholder API
    - Sodium
- Edit > Resource Packs > Download Packs
    - Faithful 64x
- Edit > Shader Packs > Download Packs
    - Complementary Reimagined
        
### BTRFS: Disable COW for Minecraft Worlds

```bash
chattr +C "$HOME"/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/instances/*/minecraft/saves
```

