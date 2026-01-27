# Firefox

## about:config

- media.hardware-video-decoding.enabled = `true`
- browser.sessionstore.interval = `300000`
- browser.sessionstore.resume_from_crash = `false`
- browser.cache.disk.enable = `false`
- browser.cache.memory.enable = `true`
    
- **4 GB RAM**
    - browser.cache.memory.capacity = `65536`
    - browser.cache.memory.max_entry_size = `5120`
    
- **6 GB RAM**
    - browser.cache.memory.capacity = `131072`
    - browser.cache.memory.max_entry_size = `10240`
    
- **8 GB RAM**
    - browser.cache.memory.capacity = `262144`
    - browser.cache.memory.max_entry_size = `20480`
    
- **12 GB RAM**
    - browser.cache.memory.capacity = `393216`
    - browser.cache.memory.max_entry_size = `30720`

- **16 GB RAM**
    - browser.cache.memory.capacity = `524288`
    - browser.cache.memory.max_entry_size = `40960`
    
- **24 GB RAM**
    - browser.cache.memory.capacity = `786432`
    - browser.cache.memory.max_entry_size = `46080`
    
- **>=32 GB RAM**
    - browser.cache.memory.capacity = `1048576`
    - browser.cache.memory.max_entry_size = `51200`
    
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

## LibreWolf Settings

- **Settings>Privacy & Security**
    - Select `Enable HTTPS-Only Mode in all windows`
    
- **Settings>LibreWolf**
    - Uncheck `Enable ResistFingerprinting`
        - Uncheck `Enable letterboxing`
        - Uncheck `Silently block canvas access requests`
    - Check `Enable WebGL`
