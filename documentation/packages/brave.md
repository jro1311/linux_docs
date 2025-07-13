# Brave

## brave://flags

- #middle-button-autoscroll - `Enabled`

## Extensions

- Dark Reader
- Bitwarden
- SponsorBlock
- Return YouTube Dislike
- Feeder
- Todoist
- Youtube-shorts block

## Add Launch Arguments on GNOME

```bash
sudo cp -v /usr/share/applications/brave-browser.desktop "$HOME/.local/share/applications/"
sudo nano "$HOME/.local/share/applications/brave-browser.desktop" 
```

## Launch Arguments

- **Store browser cache in RAM**

`--disk-cache-dir=/dev/shm/brave-cache --media-cache-dir=/dev/shm/brave-cache`

## Settings

- **Trackers & ads blocking** 
    - `Aggressive`
    
- **Upgrade connections to HTTPS**
    - `Standard`
    
- **Block cookies** 
    - `Allow all cookies`
