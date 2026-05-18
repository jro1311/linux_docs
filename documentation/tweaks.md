# Tweaks

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

3. **Update Manager**
    - View>Linux Kernels
        - Remove old kernels

4. **ProtonPlus**
    - Download and install latest Proton GE
    
5. **Steam**
    - Settings>Compatibility
        - Default compatibility tool: `Proton Experimental`
        
6. **CoreCtrl**
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
        
7. **Text Editor**
    - Change theme to either `Cobalt`, `Solarized Dark` or `Oblivion`

    ```bash
    # Set micro and nano to use tabs instead of spaces
    sed -i 's/"tabstospaces": true/"tabstospaces": false/' "$HOME/.config/micro/settings.json"
    sed -i 's/set tabstospaces/#set tabstospaces/' "$HOME/.config/nano/nanorc"
    sudo sed -i 's/set tabstospaces/#set tabstospaces/' /etc/nanorc
    ```
    
8. **Settings>Night Light**
    - Enable at a low setting
    
9. **LibreWolf (about:config)**
    - browser.cache.disk.enable = `false`
    - browser.sessionstore.resume_from_crash = `false`
    - browser.sessionstore.interval = `300000`
    - browser.cache.memory.capacity = `131072`
    - browser.cache.memory.max_entry_size = `2048`
    - browser.privatebrowsing.forceMediaMemoryCache = `true`
    - media.memory_cache_max_size = `65536`
    
10. **Brave**
    - brave://flags 
        - #middle-button-autoscroll: `Enabled`
        
    - Trackers & ads blocking 
        - `Aggressive`
        
    - Upgrade connections to HTTPS 
        - `Standard`
        
    - Block cookies 
        - `Allow all cookies`
    
11. **Extensions**
    - Install `Blur Cinnamon` and `Dynamic Wallpaper`
