# Setup Guide
## Initial Setup
1. After first boot, install and set up timeshift or btrfs-assistant, then create a manual snapshot
2. Add mount options to /etc/fstab, then reboot
    **universal**
        - noatime
        - nofail (for secondary drives) 
    - **btrfs**
        - compress=zstd:1
        - autodefrag (for HDDs)
    - **f2fs**
        - compress_algorithm=zstd:1
3. Copy `linux_docs` folder from the USB drive to `$HOME/Documents/`
4. In the `scripts` directory, make `chmod_scripts.sh` executable and run it in the terminal, then run `setup_system.sh`, then reboot

```bash
cd "$HOME/Documents/linux_docs/scripts"
chmod +x ./chmod_scripts.sh
./chmod_scripts.sh
./setup_system.sh
```

5. Create another manual snapshot of the current working system, then delete previous snapshot(s)

## Snapshot Retention (timeshift/snapper/btrfs-assistant)
### Minimum (safe baseline)
- Weekly: `2`
- Daily: `3`

### Recommended (optimal protection)
- Weekly: `3`
- Daily: `7`

## Linux Mint
### Update Manager
- Preferences > Automation
    - Package Updates: `Enabled`
    - Other Updates: `Enabled`
    - Automatic Maintenance: `Enabled`

## Desktops
### Cinnamon
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
- View>User Interface
    - Select `Tabbed`

## Firefox
### Settings
- Privacy & Security
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
    
## Steam
### Settings
- **Compatibility**
    - Default compatibility tool: `Proton Experimental`
- **Downloads**
    - Uncheck: `Enable Shader pre-caching`
- **In Game**
    - Uncheck: `Enable the Steam Overlay while in-game`

### Library
- Install: `Steamworks Common Redistributables`
    
## Prism Launcher
- **Settings > General**
    - Enable MangoHud
- **Settings > Java**
    - **Minimum Memory Usage (-Xms)**
        - <= 4 GiB System RAM
            - 512 MiB
        - 6 GiB System RAM
            - 1024 MiB
        - \>=8 GiB System RAM
            - 2048 MiB
    - **Maximum Memory Usage (-Xmx)**
        - <= 4 GiB System RAM
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
- **Set up Instance**
    - Add Instance
    - Edit > Version > Install Loader
        - Fabric
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
chattr -R +C "$HOME"/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/instances/*/minecraft/saves
```

