# Firefox

## about:config

- media.hardware-video-decoding.enabled = `true`
- browser.sessionstore.interval = `300000`
- browser.sessionstore.resume_from_crash = `false`

- **Disk Cache**
    - browser.cache.disk.enable = `true`
    - browser.cache.disk_cache_ssl = `true`
    - browser.cache.disk.smart_size.enabled = `false`
    
- **64-128 GB**
    - browser.cache.disk.capacity = `1048576`
    - browser.cache.disk.max_entry_size = `524288`
    
- **256-512 GB**
    - browser.cache.disk.capacity = `2097152`
    - browser.cache.disk.max_entry_size = `1048576`
    
- **1 TB**
    - browser.cache.disk.capacity = `4194304`
    - browser.cache.disk.max_entry_size = `2097152`
    
- **>=2 TB**
    - browser.cache.disk.capacity = `8388608`
    - browser.cache.disk.max_entry_size = `4194304`
    
- **Memory Cache**
    - browser.cache.memory.enable = `true`

- **4 GB RAM**
    - browser.cache.memory.capacity = `65536`
    - browser.cache.memory.max_entry_size = `16384`
    
- **6 GB RAM**
    - browser.cache.memory.capacity = `131072`
    - browser.cache.memory.max_entry_size = `32768`
    
- **8 GB RAM**
    - browser.cache.memory.capacity = `262144`
    - browser.cache.memory.max_entry_size = `65536`
    
- **12 GB RAM**
    - browser.cache.memory.capacity = `393216`
    - browser.cache.memory.max_entry_size = `98304`

- **16 GB RAM**
    - browser.cache.memory.capacity = `524288`
    - browser.cache.memory.max_entry_size = `131072`
    
- **24 GB RAM**
    - browser.cache.memory.capacity = `1048576`
    - browser.cache.memory.max_entry_size = `262144`
    
- **32-48 GB RAM**
    - browser.cache.memory.capacity = `2097152`
    - browser.cache.memory.max_entry_size = `524288`
    
- **64-96 GB RAM**
    - browser.cache.memory.capacity = `4194304`
    - browser.cache.memory.max_entry_size = `1048576`
    
- **>=128 GB RAM**
    - browser.cache.memory.capacity = `8388608`
    - browser.cache.memory.max_entry_size = `2097152`
    
## Extensions

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

## LibreWolf Settings

- **Settings>Privacy & Security**
    - Select `Enable HTTPS-Only Mode in all windows`
    
- **Settings>LibreWolf**
    - Uncheck `Enable ResistFingerprinting`
        - Uncheck `Enable letterboxing`
        - Uncheck `Silently block canvas access requests`
    - Check `Enable WebGL`
