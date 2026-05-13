# Firefox

## about:config

- media.hardware-video-decoding.enabled = `true`
- browser.sessionstore.interval = `300000`
- browser.sessionstore.resume_from_crash = `false`
- browser.cache.disk.enable = `false`
- browser.cache.memory.enable = `true`
- browser.cache.memory.max_entry_size = `2048`
    
- **4 GiB RAM**
    - browser.cache.memory.capacity = `32768`
    
- **6 GiB RAM**
    - browser.cache.memory.capacity = `49152`
    
- **8 GiB RAM**
    - browser.cache.memory.capacity = `65536`
    
- **12 GiB RAM**
    - browser.cache.memory.capacity = `98304`

- **>=16 GiB RAM**
    - browser.cache.memory.capacity = `131072`
    
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
