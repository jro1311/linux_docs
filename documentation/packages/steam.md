# Steam
## Settings
- **Compatibility**
    - Default compatibility tool: `Proton Experimental`
- **Downloads**
    - Disable: `Shader pre-caching`
- **In Game**
    - Disable: `Steam Overlay while in-game`

## Library
- Install: `Steamworks Common Redistributables`

## Fix "Couldn't set up Steam data" Error
```bash
mv ~/.steam/steam/* ~/.local/share/Steam/
rmdir ~/.steam/steam
ln -s ../.local/share/Steam ~/.steam/steam
rm -rf ~/.steam/bin
```

## Kernel Parameters
- **preempt=full** 
    - Solves audio crackling in games and improves performance

## Launch Options
- **%command%**
    - Suffix for executing Proton-specific launch options
- **mangohud**
    - Enables MangoHud overlay
    - `--dlsym`
        - Enables dlsym hooking in OpenGL games
- **DXVK_CONFIG="dxgi.maxFrameRate = X"**
    - Framerate limiter
- **DXVK_FRAME_RATE=X**
    - Framerate limiter (legacy)
- **LD_PRELOAD=""**
    - Overrides or adds specific shared libraries before a game is launched
    - Solves stuttering issues when moving mouse after a duration of playtime
- **PROTON_USE_WINED3D=1**
    - Forces Proton to use OpenGL-based wined3d instead of Vulkan-based DXVK for d3d11 and d3d10
- **PROTON_ENABLE_WAYLAND=1**
    - Enables Proton to use native Wayland instead of Xwayland
- **PROTON_ENABLE_HDR=1**
    - Enables HDR support
- **PROTON_FSR4_UPGRADE=1**
    - Enables FSR4 support
- **PROTON_DLSS_UPGRADE=1**
    - Enables DLSS support
- **PROTON_XESS_UPGRADE=1**
    - Enables XESS support

## Tools
- **Steamworks Common Redistributables** 
    - Required for some games to work
- **Proton GE**
    - https://github.com/GloriousEggroll/proton-ge-custom
    
## Windows Save Files and Documents
- `$HOME/.local/share/Steam/steamapps/compatdata/game_id/pfx/drive_c/users/steamuser/`

## Problematic Games
- **Sid Meier's Civilization III**
    - Visual artifacts when selecting units
    
## Confirmed Working Games
- Age of Empires II (2013)
- American Truck Simulator
- Barony
- Bioshock Remastered
- Bioshock 2 Remastered
- Borderlands 2
- Borderlands 3
- Borderlands: The Pre-Sequel
- CHRONO TRIGGER
- Cities Skylines
- Counter-Strike: Source
- Darkest Dungeon
- Deus Ex: Game of the Year Edition
- Dishonored
- Dragon Ball FighterZ
- Fallout 4
- Fallout New Vegas
- Far Cry 3
- FEZ
- Grand Theft Auto V
- Half-Life
- Halo: The Master Chief Collection
- Heavy Bullets
- Horizon Chase Turbo
- Just Cause 2
- Just Cause 3
- LEGO Lord of the Rings
- Killing Floor
- Mass Effect Legendary Edition
- Minecraft
- Mirror's Edge
- Mount & Blade: Warband
- Naruto Ultimate Ninja Storm
- Ravenfield
- Rogue Legacy
- Sid Meier's Civilization V
- Sid Meier's Civilization VI
- Sonic & All-Stars Racing Transformed Collection
- Slay the Spire
- Slime Rancher
- Stardew Valley
- Star Wars Battlefront II (Classic, 2005)
- Star Wars Jedi Knight: Jedi Academy
- Star Wars Knights of the Old Republic
- Star Wars Knights of the Old Republic II: The Sith Lords
- Terraria
- The Elder Scrolls III: Morrowind
- The Elder Scrolls IV: Oblivion
- The Elder Scrolls V: Skyrim Special Edition
- The Elder Scrolls Online
- The Witcher: Enhanced Edition
- The Witcher 2: Assassin of Kings Enhanced Edition
- The Witcher 3: Wild Hunt
- Thief II: The Metal Age
- Torchlight
- Torchlight 2
- Ultimate Epic Battle Simulator
- Undertale
- War Thunder
- World of Tanks
    
## Game-Specific Configuration
- **Borderlands 2**
    - Proton: `Any`
    - Launch Options: `LD_PRELOAD="" -nolauncher -nostartupmovies`
    
- **Borderlands: The Pre-Sequel**
    - Proton: `Any`
    - Launch Options: `LD_PRELOAD="" -nolauncher -nostartupmovies`
    
- **Cities Skylines**
    - Proton: `Experimental or GE`
    
- **Counter-Strike: Source**
    - Native
    - Launch Options: `+fps_max 160`
    
- **Dishonored**
    - Launch Options: `-nolauncher -nostartupmovies`
    
- **Dragon Ball FighterZ**
    - Proton: `GE`
    
- **Fallout 4**
    - Launch Options: `DXVK_CONFIG="dxgi.maxFrameRate = 60"`
    - Locations
        - `"$HOME/.local/share/Steam/steamapps/common/Fallout 4/Fallout4/Fallout4Prefs.ini"`
        - `"$HOME/.local/share/Steam/steamapps/compatdata/377160/pfx/drive_c/users/steamuser/My Documents/My Games/Fallout4/Fallout4Prefs.ini"`
    - Disable depth of field, bokeh, and mouse acceleration
    
        ```
        bDoDepthOfField=0
        bScreenSpaceBokeh=0
        bMouseAcceleration=0
        ```
        
    - **Mods**
        - Fallout 4 Script Extender (F4SE)
            - Rename `Fallout4Launcher.exe` to `Fallout4Launcher.exe.bak`
            - Rename `f4se_launcher.exe` to `Fallout4Launcher.exe`
        - Address Library for F4SE Plugins
        - High FPS Physics Fix
        - Fog Remover - Performance Enhancer II
        - Achievements Mods Enabler
        
- **Fallout New Vegas**
    - Launch Options: `DXVK_CONFIG="dxgi.maxFrameRate = 60" mangohud %command%`
    - Locations
        - `"$HOME/.local/share/Steam/steamapps/common/Fallout New Vegas/Fallout_default.ini"`
        - `"$HOME/.local/share/Steam/steamapps/compatdata/22380/pfx/drive_c/users/steamuser/Documents/My Games/FalloutNV/FalloutPrefs.ini"`
        - `"$HOME/.local/share/Steam/steamapps/compatdata/22380/pfx/drive_c/users/steamuser/Documents/My Games/FalloutNV/Fallout.ini"`
    - Disable mouse acceleration
    
        ```
        [Controls]
        fForegroundMouseAccelTop=0
        fForegroundMouseBase=0
        fForegroundMouseMult=0
        ```
        
    - **Mods**
        - FNV 4GB Patch for Linux
            - Copy executable into game installation directory
            - Open a terminal inside the directory
            - `chmod +x ./FalloutNVPatcher && ./FalloutNVPatcher`
        - New Vegas Script Extender (NVSE)
            1. Rename `FalloutNVLauncher.exe` to `FalloutNVLauncher.exe.bak`
            2. Rename `nvse_launcher.exe` to `FalloutNVLauncher.exe`
        - NMCs Textures NV Large Pack
        - New Vegas Tick Fix (NVTF)
        - New Vegas Tick Fix INI (NVTF - INI)
        - OneTweak
    
- **Just Cause 3**
    - Launch Options: `--vfs-fs dropzone --vfs-archive patch_win64 --vfs-archive archives_win64 --vfs-archive dlc_win64 --vfs-fs .`
    
- **Mirror's Edge**
    - Locations
        - `"$HOME/.local/share/Steam/steamapps/compatdata/17410/pfx/drive_c/users/steamuser/Documents/EA Games/Mirror's Edge/TdGame/Config/TdEngine.ini"`
    - Uncap framerate and disable bloom
    
        ```
        bSmoothFrameRate=False
        Bloom=False
        QualityBloom=False
        ```
        
- **Mount & Blade: Warband**
    - Use proton tricks to install DXSETUP.exe
    
- **Star Wars Battlefront II (Classic, 2005)**
    - Launch Options: `/fixedrate 160`
    
- **Star Wars Jedi Knight: Jedi Academy**
    - Custom configuration
        ```bash
        echo "devmapall
        set helpusobi 1
        set sv_cheats 1
        set r_mode "-1"
        set r_customwidth "2560"
        set r_customheight "1440"
        set cg_fov "110"
        com_maxfps 160" > "$HOME/.local/share/Steam/steamapps/common/Jedi Academy/GameData/base/autoexec.cfg"
        ```
    
- **Star Wars Knights of the Old Republic II: The Sith Lords**
    - Native
    
- **The Elder Scrolls III: Morrowind**
    - Install OpenMW
        - `flatpak install flathub -y org.openmw.OpenMW`
        
- **The Elder Scrolls IV: Oblivion**
    - Locations
        - `"$HOME/.local/share/Steam/steamapps/compatdata/22330/pfx/drive_c/users/steamuser/Documents/My Games/Oblivion/"`
    - https://en.uesp.net/wiki/Oblivion:Ini_Settings
    - Skip intro movies
        - Remove file names after "SIntroSequence=" and "SMainMenuMovieIntro=" in Oblivion.ini
    - **Mods**
        - Oblivion Script Extender (OBSE)
            1. Rename `OblivionLauncher.exe` to `OblivionLauncher.exe.bak`
            2. Rename `obse_launcher.exe` to `OblivionLauncher.exe`
        - Unofficial Oblivion Patch
        - Dynamic Map
            - In `Oblivion/Data/Ini/Dynamic Map base.ini`
                - `set tnoDM.zoomIn to 264`
                - `set tnoDM.zoomOut to 265`
        - MenuQue
        - SkyBSA
        - Better Water
        - All +5 Attribute Modifiers
        - Skip Intro and Random Start
        
- **The Elder Scrolls V: Skyrim Special Edition**
    - Locations
        - `"$HOME/.steam/steam/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/Documents/My Games/Skyrim Special Edition/"`
    - **Mods**
        - Skyrim Script Extender (SKSE)
            1. Rename `SkyrimSELauncher.exe` to `SkyrimSELauncher.exe.bak`
            2. Rename `skse64_launcher.exe` to `SkyrimSELauncher.exe`
        - Unofficial Skyrim Special Edition Patch
        - Address Library for SKSE Plugins
        - SSE Display Tweaks
        - Stones of Barenziah Quest Markers
        
- **The Elder Scrolls Online**
    - Proton: Experimental or GE
    - At startup, if launcher wants to redownload the entire game
        1. Click game options, then click cancel
        2. Click game options again, then click repair
        
- **The Witcher: Enhanced Edition**
    - Required: `Steamworks Common Redistributables`
    - Locations
        - `"$HOME/.local/share/Steam/steamapps/compatdata/20900/pfx/drive_c/users/steamuser/My Documents/The Witcher/saves/"`
    
- **The Witcher 2: Assassin of Kings Enhanced Edition**
    - Proton: `Experimental or GE`
    
- **The Witcher 3: Wild Hunt**
    - Launch Options: `--launcher-skip`
    
- **Torchlight**
    - Locations
        - `"$HOME/.local/share/Steam/steamapps/compatdata/41500/pfx/drive_c/users/steamuser/AppData/Roaming/runic games/torchlight"`
    - https://strategywiki.org/wiki/Torchlight/Console
    
- **Torchlight 2**
    - Proton: `Experimental or GE`
