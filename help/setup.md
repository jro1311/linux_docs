# Setup Guide

1. After first boot install and set up timeshift or btrfs-assistant, then create a manual snapshot
2. Add mount options to /etc/fstab, then reboot
- **btrfs**
    - compress-force=zstd:1
    - noatime
    - autodefrag (for HDDs)
    - nofail (for secondary drives)
- **ext4**
    - noatime
    - discard (for SSDs)
    - nofail (for secondary drives)
- **f2fs**
    - compress_algorithm=zstd:1
    - noatime
    - discard (for SSDs)
    - nofail (for secondary drives)
3. Upgrade system, then reboot again
4. Copy linux_docs folder from the USB drive to $HOME/Documents
5. In the `scripts` directory, make `chmod.sh` executable and run it in the terminal, then run `universal_distro_setup.sh`

```bash
chmod +x ./chmod.sh
./chmod.sh
./distro_setup.sh
reboot
```

5. Create another manual snapshot of the current working system, then delete the first snapshot

# Post-Install Tweaks

## LibreOffice

- View>User Interface
    - Select `Tabbed`

## Firefox

### about:config

- `media.hardware-video-decoding.enabled = true`
- `browser.sessionstore.interval = 300000`
- `browser.sessionstore.resume_from_crash = false`

- **4 GB RAM**
    - `browser.cache.disk.enable = true`
    - `browser.cache.disk_cache_ssl = true`
    - `browser.cache.disk.smart_size.enabled = true`
    - `browser.cache.disk.max_entry_size = 131072`
    - `browser.cache.memory.enable = true`
    - `browser.cache.memory.capacity = 131072`
    - `browser.cache.memory.max_entry_size = 65536`
    
- **6-8 GB RAM**
    - `browser.cache.disk.enable = true`
    - `browser.cache.disk_cache_ssl = true`
    - `browser.cache.disk.smart_size.enabled = true`
    - `browser.cache.disk.max_entry_size = 262144`
    - `browser.cache.memory.enable = true`
    - `browser.cache.memory.capacity = 262144`
    - `browser.cache.memory.max_entry_size = 131072`
    
- **12 GB RAM**
    - `browser.cache.disk.enable = false`
    - `browser.cache.disk_cache_ssl = false`
    - `browser.cache.memory.enable = true`
    - `browser.cache.memory.capacity = 524288`
    - `browser.cache.memory.max_entry_size = 262144`

- **>=16 GB RAM**
    - `browser.cache.disk.enable = false`
    - `browser.cache.disk_cache_ssl = false`
    - `browser.cache.memory.enable = true`
    - `browser.cache.memory.capacity = 1048576`
    - `browser.cache.memory.max_entry_size = 524288`

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
- Youtube-shorts block

### LibreWolf Settings

- **Settings>Privacy & Security**
    - Select `Enable HTTPS-Only Mode in all windows`
    
- **Settings>LibreWolf**
    - Uncheck `Enable ResistFingerprinting`
        - Uncheck `Enable letterboxing`
        - Uncheck `Silently block canvas access requests`
    - Check `Enable WebGL`
    
## Brave

### brave://flags

- #middle-button-autoscroll - `Enabled`

### Extensions

- Dark Reader
- Bitwarden
- SponsorBlock
- Return YouTube Dislike
- Feeder
- Todoist
- Youtube-shorts block

### Add Launch Arguments on GNOME

```bash
sudo cp -v /usr/share/applications/brave-browser.desktop "$HOME/.local/share/applications/"
sudo nano "$HOME/.local/share/applications/brave-browser.desktop" 
```

### Launch Arguments

- **Store browser cache in RAM**
    - Recommended only for systems with at least 12 GB RAM

`--disk-cache-dir=/dev/shm/brave-cache --media-cache-dir=/dev/shm/brave-cache`

### Settings

- **Trackers & ads blocking** 
    - `Aggressive`
    
- **Upgrade connections to HTTPS**
    - `Standard`
    
- **Block cookies** 
    - `Allow all cookies`
    
## LACT

### RX 6650 XT

- **Performance Level:** `Manual`
- **Power Profile Mode:** `3D_FULL_SCREEN`
- **Power usage limit:** `134 W`
- **Clockspeed and Voltage**
    - Max GPU Clock: `2500 MHz`
    - GPU voltage offset `-80 mV`

### RX 580

- **Performance Level:** `Manual`
- **Power Profile Mode:** `3D_FULL_SCREEN`
- **Power usage limit:** `75 W`
- **Clockspeed and Voltage**
    - Max GPU Clock: `Default`
    - GPU voltage offset: `-75 mV`

## Steam

- **Settings>Compatibility**
    - Run other titles with latest stable Proton
    
- **Settings>Downloads**
    - Uncheck `Enable Shader pre-caching`
    
- **Settings>In Game**
    - Uncheck `Enable the Steam Overlay while in-game`
    
- **Library>Tools**
    - Install `Steamworks Common Redistributables`

## Cinnamon

### Extensions

- **Blur Cinnamon**
- **Dynamic Wallpaper**

### Terminal

- **Text and background color:** `Solarized dark`
- **Palette:** `XTerm`
- **Transparent background:** `~20%`

### System Settings

- **Preferences>General**
    - Check `Disable compositing for full-screen windows`
    
- **Administration>Firewall**
    - Select `Home` profile
    - Enable
    
- **Enable Night Light**

## GNOME

### Extensions

- **ArcMenu** - arcmenu@arcmenu.com
- **Bluetooth battery indicator** - bluetooth-battery@michaelw.github.com
- **Blur my Shell** - blur-my-shell@aunetx
- **Color Picker** - color-picker@tuberry
- **Dash to Panel** - dash-to-panel@jderose9.github.com
- **Gtk4 Desktop Icons NG (DING)** - gtk4-ding@smedius.gitlab.com
- **Legacy (GTK3) Theme Scheme Auto Switcher** - legacyschemeautoswitcher@joshimukul29.gmail.com
- **No overview at start-up** - no-overview@fthx
- **Vitals** - Vitals@CoreCoding.com
- **Weather O'Clock** - weatheroclock@CleoMenezesJr.github.io

## KDE Plasma

### Keyboard Shortcuts

- **System Settings>Keyboard>Shortcuts**
    - Command:  `systemctl --user restart plasma-plasmashell`
    - Shortcut: `Ctrl+Alt+Esc`
        
### Panel

- **Add pager to panel and move to preferred location**
    - Right click>Add Virtual Desktop
    - Right click>Configure pager
        - Check `Show application icons on window outlines`
        - Text display: `No text`
    - Right click>Configure Virtual Desktops
        - Rows: `1`
        - Check `Show animation when switching: Slide`
        - Check `Show on-screen display when switching: 500 ms`
        - Check `Show desktop layout indicators`
        - Edit names (e.g. Admin, Web, Game, Misc)
    - Switch between virtual desktops using scroll wheel while hovering over them
    
### Settings

- **Settings>Software Update**
    - Notification frequency: `Weekly`
    - Apply system updates: `After rebooting`

## Xfce

### Keyboard Shortcuts

- **Settings>Hardware>Keyboard>Application Shortcuts**
    - Command:  `xfce4-popup-whiskermenu`
    - Shortcut: `Super L` (Super/Meta/Windows Key)

### Whisker Menu

- **Right-click Panel>Panel Preferences>Items>Add Whisker Menu**

## HP Printer Setup

1. Install the `hplip` and `hplip-gui` packages
2. Launch `HP Setup`
3. Add the local IP address of the printer to manual discovery 
    - e.g., 192.168.0.180
