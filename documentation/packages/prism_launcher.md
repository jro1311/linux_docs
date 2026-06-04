# Prism Launcher
## Settings
- **General**
    - Enable MangoHud
- **Java**
    - **Minimum Memory Usage (-Xms)**
        - <=4 GiB System RAM
            - 512 MiB
        - 6 GiB System RAM
            - 1024 MiB
        - \>=8 GiB System RAM
            - 2048 MiB
    - **Maximum Memory Usage (-Xmx)**
        - <=4 GiB System RAM
            - 1024 MiB
        - 6 GiB System RAM
            - 2048 MiB
        - \>=8 GiB System RAM
            - 4096 MiB
        - **Modding Levels**
            - Light
                - 4096 MiB
            - Medium
                - 6144 MiB
            - Heavy
                - 8192 MiB
                
## Instance Setup
- Add Instance > Custom
    - Version: Newest release
    - Mod Loader: `Fabric`
- Edit > Mods > Download Mods
    - Cloth Config v26\.1
    - Fabric API
    - FallingTree
    - Iris
    - Journeymap
    - Mod Menu
    - Placeholder API
    - Sodium
- Edit > Resource Packs > Download Packs
    - Faithful 64x
- Edit > Shader Packs > Download Packs
    - Complementary Reimagined
     
## BTRFS: Disable COW for Minecraft Worlds

```bash
chattr +C "$HOME"/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/instances/*/minecraft/saves
```
