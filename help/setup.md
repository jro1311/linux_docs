# General Setup

1. After first boot install and set up timeshift or btrfs-assistant, then create a manual snapshot
2. Add mount options to /etc/fstab
- btrfs
    - compress-force=zstd:1
    - noatime
    - autodefrag (for HDDs)
    - nofail (for secondary drives)
- ext4
    - noatime
    - discard (for SSDs)
    - nofail (for secondary drives)
- f2fs 
    - compress_algorithm=zstd:1
    - noatime
    - discard (for SSDs)
    - nofail (for secondary drives)
3. Copy linux_docs folder from USB drive to ~/Documents/
4. In ~/Documents/linux_docs/scripts/, make chmod.sh executable and run it in the terminal, then run the setup script for the distribution
    - chmod +x ./chmod.sh
    - ./chmod.sh
    - ./distro_setup.sh
    - reboot
5. Create another manual snapshot of the current working system, then delete the first snapshot

# Post-Install Tweaks

## LibreOffice

- View>User Interface>Tabbed
    - Change view to tabbed

## Firefox (about:config)

- media.hardware-video-decoding.enabled=true
- browser.cache.disk.enable=false
- browser.cache.disk_cache_ssl=false
- browser.cache.memory.enable=true
- browser.sessionstore.interval=300000
- browser.sessionstore.resume_from_crash=false
    
## Brave

- sudo cp -v /usr/share/applications/brave-browser.desktop ~/.local/share/applications/
- sudo nano ~/.local/share/applications/brave-browser.desktop
    - Find the line with Exec and add: --disk-cache-dir=/dev/shm/brave-cache --media-cache-dir=/dev/shm/brave-cache
- Settings
    - Trackers & ads blocking - Aggressive
    - Upgrade connections to HTTPS - Standard
    - Block cookies - Allow all cookies
- brave://flags
    - #middle-button-autoscroll - Enabled
    - #enable-vulkan - Enabled

## Steam

- Settings>Compatibility
    - Run other titles with latest stable Proton
- Settings>Downloads 
    - Uncheck "Enable Shader pre-caching"
- Settings>In Game
    - Uncheck "Enable the Steam Overlay while in-game"
- Library>Tools
    - Install Steamworks Common Redistributables

## LACT (OC)

### RX 6650 XT

- Performance Level: Manual
- Power Profile Mode: Compute
- Power Usage Limit: 134W
- Clockspeed and Voltage
    - GPU voltage offset -80 mV
    - Max GPU Clock 2500 MHz

### RX 580

- Performance Level: Manual
- Power Profile Mode: 3D_FULL_SCREEN
- Power usage limit: 75 W
- Clockspeed and Voltage
    - GPU voltage offset: -75 mV
    - Max GPU Clock: N/A

## Cinnamon

- System Settings>Preferences>General
    - Enable "Disable compositing for full-screen windows"

## KDE Plasma

- Settings>Software Update
    - Notification frequency: Weekly
    - Apply system updates: After rebooting
- Add pager to panel and move to preferred location
    - Right click>Add Virtual Desktop (x2)
    - Right click>Configure pager
        - Check "Show application icons on window outlines"
        - Text display: No text
    - Right click>Configure Virtual Desktops
        - Rows: 1
        - Check "Show animation when switching: Slide"
        - Check "Show on-screen display when switching: 500 ms"
        - Check "Show desktop layout indicators"
        - Edit names (e.g. Admin, Web, Game, Misc)
    - Switch between virtual desktops using scroll wheel while hovering over them
