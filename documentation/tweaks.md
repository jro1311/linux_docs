# Tweaks

1. **Upgrade system and install newest kernel, reboot, then remove old kernels**

2. **Remove old folder, then change directory, then clone git repo**

```bash
rm -rv "$HOME/Documents/linux_docs"
cd "$HOME/Documents/"
git clone https://github.com/jro1311/linux_docs.git
```

3. **Change directory, make all scripts executable, then run tweaks.sh**

```bash
cd "$HOME/Documents/linux_docs/scripts/"
chmod +x ./chmod.sh
./chmod.sh
./tweaks.sh
```

4. **LACT**

- **Performance Level:** `Manual`
- **Power Profile Mode:** `3D_FULL_SCREEN`
- **Power usage limit:** `75 W`
- **Clockspeed and Voltage**
    - Max GPU Clock: `Default`
    - GPU voltage offset: `-75 mV`
        
5. **Text Editor**
    - Change theme to either `Cobalt`, `Solarized Dark` or `Oblivion`
    
6. **Settings>Night Light**
    - Enable at a low setting
    
7. **Extensions**
    - Install `Blur Cinnamon` and `Dynamic Wallpaper`
    
8. **Brave**
    - Trackers & ads blocking
        - `Aggressive`
        
    - Upgrade connections to HTTPS
        - `Standard`
        
    - Block cookies
        - `Allow all cookies`
        
    - brave://flags
        - #middle-button-autoscroll: `Enabled`
        
    - Launch Arguments
        - `--disk-cache-dir=/dev/shm/brave-cache --media-cache-dir=/dev/shm/brave-cache`
        
9. **Firefox (about:config)**
    - media.hardware-video-decoding.enabled = `true`
    - browser.sessionstore.interval = `300000`
    - browser.sessionstore.resume_from_crash = `false`
    - browser.cache.disk.enable = `false`
    - browser.cache.memory.enable = `true`
    - browser.cache.memory.capacity = `524288`
    - browser.cache.memory.max_entry_size = `131072`
