# Tweaks

1. **Remove old folder, then change directory, then clone git repo**

```bash
rm -rv "$HOME/Documents/linux_docs"
cd "$HOME/Documents/"
git clone https://github.com/jro1311/linux_docs.git
```

2. **Change directory, make all scripts executable, then run tweaks.sh**

```bash
cd "$HOME/Documents/linux_docs/scripts/"
chmod +x ./chmod.sh
./chmod.sh
./tweaks.sh
```

3. **LACT**

- **Performance Level:** `Manual`
- **Power Profile Mode:** `3D_FULL_SCREEN`
- **Power usage limit:** `75 W`
- **Clockspeed and Voltage**
    - Max GPU Clock: `Default`
    - GPU voltage offset: `-75 mV`
        
4. **Text Editor**
    - Change theme to `Cobalt` or `Solarized Dark`
    
5. **Settings>Night Light**
    - Enable at a low setting
    
6. **Extensions**
    - Install `Blur Cinnamon`
    - Install `Dynamic Wallpaper`
    
7. **Brave**
    - Trackers & ads blocking
        - `Aggressive`
    - Upgrade connections to HTTPS
        - `Standard`
    - Block cookies
        - `Allow all cookies`
    - `brave://flags`
        - #middle-button-autoscroll: `Enabled`
        
8. **Firefox (about:config)**
    - media.hardware-video-decoding.enabled = `true`
    - browser.sessionstore.interval = `300000`
    - browser.sessionstore.resume_from_crash = `false`
    - browser.cache.disk.enable = `false`
    - browser.cache.memory.enable = `true`
    - browser.cache.memory.capacity = `1048576`
    - browser.cache.memory.max_entry_size = `262144`
    
9. **Steam**
    - Change default Proton version from experimental to latest stable
