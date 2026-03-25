# Tweaks

1. Change `compress-force` to `compress` in /etc/fstab, then reboot

```bash
sudo nano /etc/fstab
```

2. Remove old linux_docs folder, then change directory, then clone git repo

```bash
rm -rfv "$HOME/Documents/linux_docs"
cd "$HOME/Documents/"

if ! command -v git >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y git
fi

git clone https://github.com/jro1311/linux_docs.git
```

3. Change directory, make all scripts executable, then run tweaks.sh and reboot

```bash
cd "$HOME/Documents/linux_docs/scripts/"
chmod +x ./chmod.sh
./chmod.sh
./tweaks.sh
```

4. **Update Manager**
    - View>Linux Kernels
        - Remove old kernels

5. **ProtonPlus**
    - Download and install latest Proton GE
    
6. **Steam**
    - Settings>Compatibility
        - Default compatibility tool: `Proton Experimental`
        
7. **CoreCtrl**

- **Performance Level:** `Manual`
- **Power Profile Mode:** `3D_FULL_SCREEN`

- **Cool and Quiet**
    - Power Limit: `75 W`
    - Max GPU Clock: `Default`
    - GPU Voltage Offset: `-75 mV`

- **Performance**
    - Power Limit: `100 W`
    - Max GPU Clock: `Default`
    - GPU Voltage Offset: `-75 mV`
        
8. **Text Editor**
    - Change theme to either `Cobalt`, `Solarized Dark` or `Oblivion`
    
9. **Settings>Night Light**
    - Enable at a low setting
    
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
    - browser.cache.memory.capacity = `262144`
    - browser.cache.memory.max_entry_size = `20480`
    
12. **GNOME Disk Utility**
    - Add `ntfs-3g` mount option if you are mounting ntfs partition
    
13. **Extensions**
    - Install `Blur Cinnamon` and `Dynamic Wallpaper`
