# Firefox

## about:config

- `media.hardware-video-decoding.enabled = true`
- `browser.sessionstore.interval = 300000`
- `browser.sessionstore.resume_from_crash = false`

- **4 GB RAM**
    - `browser.cache.disk.enable = true`
    - `browser.cache.disk_cache_ssl = true`
    - `browser.cache.disk.smart_size.enabled = true`
    - `browser.cache.disk.max_entry_size = 262144`
    - `browser.cache.memory.enable = true`
    - `browser.cache.memory.capacity = 131072`
    - `browser.cache.memory.max_entry_size = 131072`
    
- **6-8 GB RAM**
    - `browser.cache.disk.enable = true`
    - `browser.cache.disk_cache_ssl = true`
    - `browser.cache.disk.smart_size.enabled = true`
    - `browser.cache.disk.max_entry_size = 524288`
    - `browser.cache.memory.enable = true`
    - `browser.cache.memory.capacity = 262144`
    - `browser.cache.memory.max_entry_size = 262144`
    
- **12 GB RAM**
    - `browser.cache.disk.enable = false`
    - `browser.cache.disk_cache_ssl = false`
    - `browser.cache.memory.enable = true`
    - `browser.cache.memory.capacity = 524288`
    - `browser.cache.memory.max_entry_size = 524288`

- **>=16 GB RAM**
    - `browser.cache.disk.enable = false`
    - `browser.cache.disk_cache_ssl = false`
    - `browser.cache.memory.enable = true`
    - `browser.cache.memory.capacity = 1048576`
    - `browser.cache.memory.max_entry_size = 1048576`
    
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
    - Select "Enable HTTPS-Only Mode in all windows"
    
- **Settings>LibreWolf**
    - Uncheck "Enable ResistFingerprinting"
        - Uncheck "Enable letterboxing"
        - Uncheck "Silently block canvas access requests"
    - Check "Enable WebGL"
