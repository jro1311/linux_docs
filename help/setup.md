1. After first boot install and set up timeshift or btrfs-assistant, then create a manual snapshot
2. Add mount options to /etc/fstab
    - btrfs
        - compress-force=zstd:1
        - noatime
        - autodefrag for HDDs
    - ext4
        - noatime
        - discard for SSDs
    - f2fs 
        - compress_algorithm=zstd:1
        - noatime
        - discard for SSDs
        - nofail for secondary drives
3. Copy linux_docs folder from USB drive to ~/Documents/
4. In ~/Documents/linux_docs/scripts/, make chmod.sh executable and run it in the terminal, then run the setup script for the distribution
    - chmod +x ./chmod.sh
    - ./chmod.sh
    - ./distro_setup.sh
    - reboot
5. Create another manual snapshot of the current working system, then delete the first snapshot
6. Tweak settings as below

# LibreOffice
- View>User Interface>Tabbed
    - Change view to tabbed

# Firefox/LibreWolf
- Enter about:config in the address bar and set the following values
    - media.hardware-video-decoding.enabled=true
    - browser.cache.disk.enable=false
    - browser.cache.disk_cache_ssl=false
    - browser.cache.memory.enable=true
    - browser.sessionstore.interval=300000
    - browser.sessionstore.resume_from_crash=false
- Settings>Privacy & Security
    - Select "Enable HTTPS-Only Mode in all windows"
- Settings>LibreWolf
    - Uncheck "Enable ResistFingerprinting"
        - Uncheck "Enable letterboxing"
        - Uncheck "Silently block canvas access requests"
    - Check "Enable WebGL"
- Install Canvas Blocker extension

# Brave
- sudo cp -v /usr/share/applications/brave-browser.desktop ~/.local/share/applications/
- sudo nano ~/.local/share/applications/brave-browser.desktop
    - Go to line Exec and add the following arguments
        - --disk-cache-dir=/dev/shm/brave-cache --media-cache-dir=/dev/shm/brave-cache
- Settings
    - Trackers & ads blocking - Aggressive
    - Upgrade connections to HTTPS - Standard
    - Block cookies - Allow all cookies
- brave://flags
    #middle-button-autoscroll - Enabled
    #enable-vulkan - Enabled

# Steam
- Settings>Compatibility
    - Enable Steam Play for all games using latest Proton stable or experimental
        - Try using Proton GE for specific games that don't work with regular proton
            - Library>Properties>Compatibility>Force>Proton GE
- Settings>Downloads
    - Disable Shader pre-caching
-Settings>In Game>Disable Steam Overlay
- Library>Tools
    - Install Steamworks Common Redistributables

# LACT 
- OC
    - Performance Level: Automatic
    - Power Profile Mode: 3D_FULL_SCREEN
    - Clockspeed and Voltage
        - RX 6650 XT
            - Power usage limit 134W
            - Max GPU Clock 2500 MHz
            - GPU voltage offset -80 mV
        - RX 580
            - Power usage limit 75W
            - GPU voltage offset -75 mV

# Cinnamon
- System Settings>Preferences>General
    - Enable "Disable compositing for full-screen windows"

# KDE Plasma
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
        
# Fedora Atomic
- rpm-ostree install btrfsmaintenance
- systemctl reboot
- sudo systemctl disable btrfs-defrag.timer
- sudo systemctl disable btrfs-trim.timer
- sudo systemctl enable btrfs-balance.timer
- sudo systemctl enable btrfs-scrub.timer
- sudo systemctl enable btrfsmaintenance-refresh.path
