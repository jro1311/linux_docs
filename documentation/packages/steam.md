# Launch Options

## MangoHud
- Enables overlay
- mangohud %command%

## LD_PRELOAD

- Solves stuttering issues when moving mouse after a duration of playtime
- LD_PRELOAD="" %command%
    - with MangoHud - LD_PRELOAD="" mangohud %command%

# Windows save files and documents

$HOME/.local/share/Steam/steamapps/compatdata/*game_id*/pfx/drive_c/users/steamuser/

# Kernel Arguments

- preempt=full - Solves audio crackling in games and improves performance

# Tools

- Steamworks Common Redistributables - Required for some games to work

# Proton GE (https://github.com/GloriousEggroll/proton-ge-custom)

- Custom version of Proton

# Problematic games

- Just Cause 2
    - Fails to launch
- Sid Meier's Civilization III 
    - Fullscreen problems
    - Visual artifacts

# Game-Specific Documentation

## Borderlands 2

- Proton: Any
- Launch Options: LD_PRELOAD="" mangohud %command% -NoLauncher -nostartupmovies

## Borderlands The Pre-Sequel

- Proton: Any
- Launch Options: LD_PRELOAD="" mangohud %command% -NoLauncher -nostartupmovies

## Cities Skylines

- Proton: Experimental or GE
- Launch Options: mangohud %command%

## Counter-Strike Source

- Native
- Launch Options: mangohud %command% +fps_max 160

## Dishonored

- Proton: Any
- Launch Options: Launch Options: mangohud %command% -NoLauncher -nostartupmovies

## Dragon Ball FighterZ

- Proton: GE
- Launch Options: Launch Options: mangohud %command%

## Fallout 4

- Proton: Any
- Launch Options: DXVK_FRAME_RATE=60 mangohud %command%

### Disable depth of field, bokeh, and mouse acceleration

- nano "$HOME/.local/share/Steam/steamapps/common/Fallout 4/Fallout4/Fallout4Prefs.ini"
- nano "$HOME/.local/share/Steam/steamapps/compatdata/377160/pfx/drive_c/users/steamuser/My Documents/My Games/Fallout4/Fallout4Prefs.ini"
    - bDoDepthOfField=0
    - bScreenSpaceBokeh=0
    - bMouseAcceleration=0

## Fallout New Vegas

- Proton: Any
- Launch Options: mangohud %command%

### Disable mouse acceleration

- nano "$HOME/.local/share/Steam/steamapps/common/Fallout New Vegas/Fallout_default.ini"
- nano "$HOME/.local/share/Steam/steamapps/compatdata/22380/pfx/drive_c/users/steamuser/Documents/My Games/FalloutNV/FalloutPrefs.ini"
- nano "$HOME/.local/share/Steam/steamapps/compatdata/22380/pfx/drive_c/users/steamuser/Documents/My Games/FalloutNV/Fallout.ini"
    - [Controls]
    - fForegroundMouseAccelTop=0
    - fForegroundMouseBase=0
    - fForegroundMouseMult=0

## Just Cause 3

- Proton: Any
- Launch Options: mangohud %command% --vfs-fs dropzone --vfs-archive patch_win64 --vfs-archive archives_win64 --vfs-archive dlc_win64 --vfs-fs .

## Minecraft

- Native
- Launch Options: mangohud --dlsym %command%

## Mirror's Edge

- Proton: Any
- Launch Options: mangohud %command%

### Uncap framerate and disable bloom

- nano "$HOME/.local/share/Steam/steamapps/compatdata/17410/pfx/drive_c/users/steamuser/Documents/EA Games/Mirror's Edge/TdGame/Config/TdEngine.ini"
    - bSmoothFrameRate=False
    - Bloom=False
    - QualityBloom=False

## Mount & Blade: Warband

- Proton: Any
- Launch Options: mangohud %command%
- Use proton tricks to install DXSETUP.exe

## Naruto Ultimate Ninja Storm

- Proton: Any
- Launch Options: mangohud %command%

## Star Wars Jedi Knight: Jedi Academy

- Proton: Any

### Custom configuration

echo "devmapall
set helpusobi 1
set sv_cheats 1
set r_mode "-1"
set r_customwidth "2560"
set r_customheight "1440"
set cg_fov "110"
com_maxfps 160" > "$HOME/.local/share/Steam/steamapps/common/Jedi Academy/GameData/base/autoexec.cfg"

## Star Wars Knights of the Old Republic

- Proton: Any
- Launch Options: mangohud %command%

## Star Wars Knights of the Old Republic II: The Sith Lords

- Native
- Launch Options: mangohud %command%

## The Elder Scrolls III: Morrowind

- Launch Options: mangohud %command%

### Install OpenMW

flatpak install flathub -y openmw

## The Elder Scrolls IV: Oblivion

- Launch Options: mangohud %command%

### Skip intro movies

nano $HOME/.local/share/Steam/steamapps/compatdata/22330/pfx/drive_c/users/steamuser/Documents/My Games/Oblivion/)
    - Remove files names under "SIntroSequence=" in Oblivion.ini)
    
### OBSE

- Rename obse_launcher.exe to OblivionLauncher.exe

## The Elder Scrolls Online

- Launch Options: LD_PRELOAD="" mangohud %command%

### At startup, if launcher wants to redownload the entire game

1. Click game options, then click cancel
2. Click game options again, then click repair

## The Witcher 1

- Launch Options: mangohud %command%
- Steamworks Common Redistributables required
- Delete save files in "$HOME/.local/share/Steam/steamapps/compatdata/20900/pfx/drive_c/users/steamuser/My Documents/The Witcher/saves/"

## The Witcher 2

- Proton: Experimental or GE
- Launch Options: mangohud %command%

## The Witcher 3: Wild Hunt

- Proton: Any
- Launch Options: mangohud %command% --launcher-skip

## Torchlight 2

- Proton: Experimental or GE
- Launch Options: mangohud %command%
