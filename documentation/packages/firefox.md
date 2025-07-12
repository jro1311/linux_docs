# Firefox

## about:config

- `media.hardware-video-decoding.enabled = true`
- `browser.sessionstore.interval = 300000`
- `browser.sessionstore.resume_from_crash = false`
- **>= 8 GB RAM systems**
    - `browser.cache.disk.enable = false`
    - `browser.cache.disk_cache_ssl = false`
    - `browser.cache.memory.enable = true`
- **<8 GB RAM systems**
    - `browser.cache.disk.enable = true`
    - `browser.cache.disk_cache_ssl = true`
    - `browser.cache.memory.enable = true`
    - `browser.cache.disk.smart_size.enabled = false`
    - `browser.cache.disk.capacity = 1024000`

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
