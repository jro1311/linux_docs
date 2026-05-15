# Firefox

## about:config

- browser.cache.disk.enable = `false`
- browser.sessionstore.resume_from_crash = `false`
- browser.sessionstore.interval = `300000`

- **<=2 GiB RAM**
    - browser.cache.memory.capacity = `32768`
    - browser.cache.memory.max_entry_size = `1024`
    
- **4 GiB RAM**
    - browser.cache.memory.capacity = `65536`
    - browser.cache.memory.max_entry_size = `2048`
    
- **6 GiB RAM**
    - browser.cache.memory.capacity = `98304`
    - browser.cache.memory.max_entry_size = `2048`
    
- **>=8 GiB RAM**
    - browser.cache.memory.capacity = `131072`
    - browser.cache.memory.max_entry_size = `2048`
    
## Betterfox Overrides (user.js)

```js
/** OCSP & CERTS / HPKP ***/
user_pref("security.OCSP.enabled", 1);

/** DISK AVOIDANCE ***/
user_pref("browser.sessionstore.resume_from_crash", false);
user_pref("browser.sessionstore.interval", 300000);
user_pref("browser.cache.memory.capacity", 131072);
user_pref("browser.cache.memory.max_entry_size", 2048);

/** MOZILLA ***/
user_pref("geo.provider.network.url", "");
```
    
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
