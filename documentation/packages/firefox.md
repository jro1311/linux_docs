# Firefox
## about:config
    - browser.cache.disk.enable = `false`
    - browser.sessionstore.resume_from_crash = `false`
    - browser.sessionstore.interval = `300000`
    - media.memory_cache_max_size = `65536`
    - **<=2 GiB System RAM**
        - browser.cache.memory.capacity = `32768`
        - browser.cache.memory.max_entry_size = `1024`
    - **4 GiB System RAM**
        - browser.cache.memory.capacity = `65536`
        - browser.cache.memory.max_entry_size = `2048`
    - **6 GiB System RAM**
        - browser.cache.memory.capacity = `98304`
        - browser.cache.memory.max_entry_size = `2048`
    - **>=8 GiB System RAM**
        - browser.cache.memory.capacity = `131072`
        - browser.cache.memory.max_entry_size = `2048`
        
## Settings
- Privacy & Security
    - Tracking Protection: `Strict`
        - Check: `Fix major site issues`
        - Check: `Fix minor site issues`
    - Select: `Enable HTTPS-Only Mode in all windows` 
    
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
    
## Betterfox Overrides (user.js)

```js
/** TRACKING PROTECTION ***/
user_pref("browser.download.start_downloads_in_tmp_dir", false);

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

## LibreWolf Overrides (user.js)

```js
/** TRACKING PROTECTION ***/
user_pref("browser.download.start_downloads_in_tmp_dir", false);
user_pref("privacy.resistFingerprinting", false);

/** DISK AVOIDANCE ***/
user_pref("browser.sessionstore.resume_from_crash", false);
user_pref("browser.sessionstore.interval", 300000);
user_pref("browser.cache.memory.capacity", 131072);
user_pref("browser.cache.memory.max_entry_size", 2048);

/** WEBGL* ***/
user_pref("librewolf.webgl.prompt", false);
```
