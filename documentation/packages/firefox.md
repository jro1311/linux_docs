# Firefox

## about:config

- media.hardware-video-decoding.enabled = `true`
- browser.sessionstore.interval = `300000`
- browser.sessionstore.resume_from_crash = `false`
- browser.cache.disk.enable = `false`
- browser.cache.memory.enable = `true`
    
- **4 GB RAM**
    - browser.cache.memory.capacity = `65536`
    - browser.cache.memory.max_entry_size = `10240`
    
- **6 GB RAM**
    - browser.cache.memory.capacity = `131072`
    - browser.cache.memory.max_entry_size = `15360`
    
- **8 GB RAM**
    - browser.cache.memory.capacity = `262144`
    - browser.cache.memory.max_entry_size = `20480`
    
- **12 GB RAM**
    - browser.cache.memory.capacity = `393216`
    - browser.cache.memory.max_entry_size = `25600`

- **16 GB RAM**
    - browser.cache.memory.capacity = `524288`
    - browser.cache.memory.max_entry_size = `40960`
    
- **24 GB RAM**
    - browser.cache.memory.capacity = `1048576`
    - browser.cache.memory.max_entry_size = `51200`
    
- **32-48 GB RAM**
    - browser.cache.memory.capacity = `2097152`
    - browser.cache.memory.max_entry_size = `102400`
    
- **>=64 GB RAM**
    - browser.cache.memory.capacity = `4194304`
    - browser.cache.memory.max_entry_size = `204800`
    
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
