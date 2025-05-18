# How to use Android Apps on Linux using Waydroid
1. Follow installation instructions for your distro (https://docs.waydro.id/usage/install-on-desktops)
2. Enable Waydroid 
    - sudo systemctl enable --now waydroid-container
3. Set up Waydroid as Vanilla Android
4. Download X86_64 APK file for selected application (on your host system, not inside Waydroid)
5. Install application
    - waydroid app install /path/to/file.apk

# Install F-Droid and Key Mapper
1. Download F-Droid X86_64 APK file (on your host system, not inside Waydroid)
2. Install application
    - waydroid app install /path/to/file.apk
3. In F-Droid, install Key Mapper
4. Add key mapping (coordinates for 1440P monitor)
    - Ctrl + z
        - Pinch in with 2 fingers on coordinates 1280/720 to with a pinch distance of 200px 100ms (Zoom In)
    - Ctrl + x
        - Pinch out with 2 fingers on coordinates 1280/720 to with a pinch distance of 200px 100ms (Zoom Out)
