# Steam

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

- **mangohud %command%**
    - Enables overlay
- **LD_PRELOAD="" %command%**
    - Solves stuttering issues when moving mouse after a duration of playtime
    - with MangoHud - LD_PRELOAD="" mangohud %command%
- **PROTON_ENABLE_WAYLAND=1 %command%**
    - Enables Proton to use native Wayland instead of Xwayland

## Tools

- **Steamworks Common Redistributables** 
    - Required for some games to work

## Proton GE

- **https://github.com/GloriousEggroll/proton-ge-custom**
    - Custom version of Proton
    
## Windows Save Files and Documents

```
$HOME/.local/share/Steam/steamapps/compatdata/game_id/pfx/drive_c/users/steamuser/
```

## Problematic Games

- **Sid Meier's Civilization III**
    - Visual artifacts when selecting units
    
## Confirmed Working Games

- **Borderlands 2**
    - Proton: `Any`
    - Launch Options: `LD_PRELOAD="" mangohud %command% -NoLauncher -nostartupmovies`
- **Borderlands The Pre-Sequel**
    - Proton: `Any`
    - Launch Options: `LD_PRELOAD="" mangohud %command% -NoLauncher -nostartupmovies`
- **Cities Skylines**
    - Proton: `Experimental or GE`
    - Launch Options: `mangohud %command%`
- **Counter-Strike Source**
    - Native
    - Launch Options: `mangohud %command% +fps_max 160`
- **Dishonored**
    - Proton: `Any`
    - Launch Options: `mangohud %command% -NoLauncher -nostartupmovies`
- **Dragon Ball FighterZ**
    - Proton: GE
    - Launch Options: `mangohud %command%`
- **Fallout 4**
    - Proton: `Any`
    - Launch Options: `DXVK_FRAME_RATE=60 mangohud %command%`
    - Disable depth of field, bokeh, and mouse acceleration
        - `"$HOME/.local/share/Steam/steamapps/common/Fallout 4/Fallout4/Fallout4Prefs.ini"`
        - `"$HOME/.local/share/Steam/steamapps/compatdata/377160/pfx/drive_c/users/steamuser/My Documents/My Games/Fallout4/Fallout4Prefs.ini"`
            ```
            bDoDepthOfField=0
            bScreenSpaceBokeh=0
            bMouseAcceleration=0
            ```
- **Fallout New Vegas**
    - Proton: `Any`
    - Launch Options: `mangohud %command%`
    - Disable mouse acceleration
        - `"$HOME/.local/share/Steam/steamapps/common/Fallout New Vegas/Fallout_default.ini"`
        - `"$HOME/.local/share/Steam/steamapps/compatdata/22380/pfx/drive_c/users/steamuser/Documents/My Games/FalloutNV/FalloutPrefs.ini"`
        - `"$HOME/.local/share/Steam/steamapps/compatdata/22380/pfx/drive_c/users/steamuser/Documents/My Games/FalloutNV/Fallout.ini"`
            ```
            [Controls]
            fForegroundMouseAccelTop=0
            fForegroundMouseBase=0
            fForegroundMouseMult=0
            ```
- **Half-Life**
    - Native
    - Launch Options: `mangohud %command%`
- **Just Cause 2**
    - Proton: `Any`
    - Launch Options: `mangohud %command%`
- **Just Cause 3**
    - Proton: `Any`
    - Launch Options: `mangohud %command% --vfs-fs dropzone --vfs-archive patch_win64 --vfs-archive archives_win64 --vfs-archive dlc_win64 --vfs-fs .`
- **Killing Floor**
    - Proton: `Any`
    - Launch Options: `mangohud %command%`
- **Mass Effect Legendary Edition**
    - Proton: `Any`
    - Launch Options: `mangohud %command%`
- **Minecraft**
    - Native
    - Launch Options: `mangohud --dlsym %command%`
- **Mirror's Edge**
    - Proton: `Any`
    - Launch Options: `mangohud %command%`
    - Uncap framerate and disable bloom
        - `"$HOME/.local/share/Steam/steamapps/compatdata/17410/pfx/drive_c/users/steamuser/Documents/EA Games/Mirror's Edge/TdGame/Config/TdEngine.ini"`
            ```
            bSmoothFrameRate=False
            Bloom=False
            QualityBloom=
            ```
- **Mount & Blade: Warband**
    - Proton: `Any`
    - Launch Options: `mangohud %command%`
    - Use proton tricks to install DXSETUP.exe
- **Naruto Ultimate Ninja Storm**
    - Proton: `Any`
    - Launch Options: `mangohud %command%`
- **Star Wars Battlefront II (Classic, 2005)**
    - Proton: `Any`
    - Launch Options: `mangohud %command% /fixedrate 160`
- **Star Wars Jedi Knight: Jedi Academy**
    - Proton: `Any`
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
- **Star Wars Knights of the Old Republic**
    - Proton: `Any`
    - Launch Options: `mangohud %command%`
- **Star Wars Knights of the Old Republic II: The Sith Lords**
    - Native
    - Launch Options: `mangohud %command%`
- **The Elder Scrolls III: Morrowind**
    - Proton: `Any`
    - Launch Options: `mangohud %command%`
    - Install OpenMW
        - `flatpak install flathub -y org.openmw.OpenMW`
- **The Elder Scrolls IV: Oblivion**
    - Proton: `Any`
    - Launch Options: `mangohud %command%`
    - Skip intro movies
        - `"$HOME/.local/share/Steam/steamapps/compatdata/22330/pfx/drive_c/users/steamuser/Documents/My Games/Oblivion/"`
            - Remove files names under "SIntroSequence=" in Oblivion.ini)
    - OBSE
        - Rename obse_launcher.exe to OblivionLauncher.exe
- **The Elder Scrolls Online**
    - Proton: Experimental or GE
    - Launch Options: LD_PRELOAD="" mangohud %command%
    - At startup, if launcher wants to redownload the entire game
        1. Click game options, then click cancel
        2. Click game options again, then click repair
- **The Witcher 1**
    - Proton: `Any`
    - Launch Options: `mangohud %command%`
    - Steamworks Common Redistributables required
    - Delete save files in `"$HOME/.local/share/Steam/steamapps/compatdata/20900/pfx/drive_c/users/steamuser/My Documents/The Witcher/saves/"`
- **The Witcher 2**
    - Proton: `Experimental or GE`
    - Launch Options: `mangohud %command%`
- **The Witcher 3: Wild Hunt**
    - Proton: `Any`
    - Launch Options: `mangohud %command% --launcher-skip`
- **Torchlight 2**
    - Proton: `Experimental or GE`
    - Launch Options: `mangohud %command%`
