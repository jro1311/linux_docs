# Tweaks

1. Change `compress-force` to `compress` in /etc/fstab, then reboot

```bash
sudo nano /etc/fstab
```

2. **Upgrade system and install newest kernel, reboot, then remove old kernels**

3. **Remove old folder, then change directory, then clone git repo**

```bash
rm -rv "$HOME/Documents/linux_docs"
cd "$HOME/Documents/"
git clone https://github.com/jro1311/linux_docs.git
```

4. **Change directory, make all scripts executable, then run tweaks.sh**

```bash
cd "$HOME/Documents/linux_docs/scripts/"
chmod +x ./chmod.sh
./chmod.sh
./tweaks.sh
```

5. **ProtonPlus**
    - Download and install latest Proton GE

6. **LACT**

- **Performance Level:** `Manual`
- **Power Profile Mode:** `3D_FULL_SCREEN`
- **Power usage limit:** `75 W`
- **Clockspeed and Voltage**
    - Max GPU Clock: `Default`
    - GPU voltage offset: `-75 mV`
        
7. **Text Editor**
    - Change theme to either `Cobalt`, `Solarized Dark` or `Oblivion`
    
8. **Settings>Night Light**
    - Enable at a low setting
    
9. **Extensions**
    - Install `Blur Cinnamon` and `Dynamic Wallpaper`
    
10. **Brave**
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
        
11. **Firefox (about:config)**
    - media.hardware-video-decoding.enabled = `true`
    - browser.sessionstore.interval = `300000`
    - browser.sessionstore.resume_from_crash = `false`
    - browser.cache.disk.enable = `false`
    - browser.cache.memory.enable = `true`
    - browser.cache.memory.capacity = `524288`
    - browser.cache.memory.max_entry_size = `40960`
    
12. **GNOME Disk Utility**
    - Add `ntfs-3g` mount option if you are mounting ntfs partition
