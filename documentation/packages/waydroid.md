# Waydroid Setup Guide
## Installation
1. Follow installation instructions for your distribution (https://docs.waydro.id/usage/install-on-desktops)
2. Enable Waydroid container 

```bash
sudo systemctl enable --now waydroid-container
```

3. Set up Waydroid as Vanilla Android
4. Download X86_64 APK file for selected application (on your host system, not inside Waydroid)
5. Install application

```bash
waydroid app install "$HOME/Downloads/file.apk"
```

## F-Droid
1. Download F-Droid X86_64 APK file (on your host system, not inside Waydroid)
2. Install F-Droid

```bash
waydroid app install "$HOME/Downloads/F-Droid.apk"
```

## Key Mapper
1. In F-Droid, install Key Mapper
2. Add key mappings

### Pinch Zoom In (2560x1440)
- Trigger: `Ctrl Left + z`
- Add Action > Input > Pinch Screen
    - X: `1280`
    - Y: `720`
    - Pinch distance (px): `200`
    - Pinch in
    - Pinch duration (ms): `100`
    - Finger count: `2`
    
### Pinch Zoom Out (2560x1440)
- Trigger: `Ctrl Left + x`
- Add Action > Input > Pinch Screen
    - X: `1280`
    - Y: `720`
    - Pinch distance (px): `200`
    - Pinch out
    - Pinch duration (ms): `100`
    - Finger count: `2`
