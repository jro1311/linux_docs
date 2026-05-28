```
.
├── configs
│   ├── applications
│   │   ├── firefox
│   │   │   └── user.js
│   │   ├── librewolf
│   │   │   └── user.js
│   │   ├── micro
│   │   │   └── settings.json
│   │   ├── mpv
│   │   │   ├── input.conf
│   │   │   └── mpv.conf
│   │   ├── btop.conf
│   │   ├── htoprc
│   │   ├── MangoHud.conf
│   │   ├── nanorc
│   │   └── redshift.conf
│   └── system
│       ├── bash
│       │   ├── bash.d
│       │   │   ├── commands
│       │   │   │   ├── clean.sh
│       │   │   │   ├── cmds.sh
│       │   │   │   ├── install.sh
│       │   │   │   ├── list_locked.sh
│       │   │   │   ├── list.sh
│       │   │   │   ├── lock.sh
│       │   │   │   ├── remove.sh
│       │   │   │   ├── search_installed.sh
│       │   │   │   ├── search.sh
│       │   │   │   ├── unlock.sh
│       │   │   │   └── upgrade.sh
│       │   │   ├── core
│       │   │   │   ├── aliases.sh
│       │   │   │   ├── env.sh
│       │   │   │   └── packages.sh
│       │   │   ├── helpers
│       │   │   │   ├── core
│       │   │   │   │   ├── config.sh
│       │   │   │   │   ├── format.sh
│       │   │   │   │   ├── selectors.sh
│       │   │   │   │   └── utils.sh
│       │   │   │   ├── domain
│       │   │   │   │   ├── desktop.sh
│       │   │   │   │   ├── games.sh
│       │   │   │   │   ├── net.sh
│       │   │   │   │   └── repo.sh
│       │   │   │   ├── info
│       │   │   │   │   ├── benchmark.sh
│       │   │   │   │   └── info.sh
│       │   │   │   └── system
│       │   │   │       ├── kargs.sh
│       │   │   │       ├── priv.sh
│       │   │   │       ├── service.sh
│       │   │   │       └── system.sh
│       │   │   └── packages
│       │   │       ├── configure
│       │   │       │   ├── appearance.sh
│       │   │       │   ├── desktop.sh
│       │   │       │   ├── ecosystem.sh
│       │   │       │   ├── gaming.sh
│       │   │       │   ├── media.sh
│       │   │       │   ├── network.sh
│       │   │       │   ├── productivity.sh
│       │   │       │   ├── system_runtimes.sh
│       │   │       │   └── system_utils.sh
│       │   │       └── install
│       │   │           ├── appearance.sh
│       │   │           ├── ecosystem.sh
│       │   │           ├── gaming.sh
│       │   │           ├── media.sh
│       │   │           ├── network.sh
│       │   │           ├── productivity.sh
│       │   │           └── system_runtimes.sh
│       │   └── bashrc
│       ├── cinnamon
│       │   └── blur_cinnamon.json
│       ├── fontconfig
│       │   └── fonts.conf
│       ├── gnome
│       │   ├── arc_menu.ini
│       │   └── dash_to_panel.ini
│       ├── network_manager
│       │   └── 10-permanent-mac-address.conf
│       ├── plasma
│       │   ├── custom_shortcuts.kksrc
│       │   ├── kwinrc
│       │   └── plasma-org.kde.plasma.desktop-appletsrc
│       ├── sysctl
│       │   ├── 99-physical-swap.conf
│       │   ├── 99-zram.conf
│       │   └── 99-zswap.conf
│       ├── xorg
│       │   └── 10-amdgpu.conf
│       ├── debian_backports.sources
│       ├── devuan_backports.sources
│       └── zram-generator.conf
├── documentation
│   ├── packages
│   │   ├── brave.md
│   │   ├── firefox.md
│   │   ├── grub.md
│   │   ├── hplip.md
│   │   ├── lightdm.md
│   │   ├── mangohud.md
│   │   ├── prism_launcher.md
│   │   ├── steam.md
│   │   ├── update_manager.md
│   │   └── waydroid.md
│   ├── resource_usage
│   │   ├── data.csv
│   │   ├── methodology.md
│   │   └── resource_usage.ods
│   ├── desktops.md
│   ├── fstab.md
│   ├── gpu_profiles.md
│   ├── kernel_parameters.md
│   ├── linux_journey.md
│   └── tweaks.md
├── help
│   ├── bash
│   │   ├── battery.sh
│   │   ├── boot_drive.sh
│   │   ├── bootloader.sh
│   │   ├── boot_mode.sh
│   │   ├── colors.sh
│   │   ├── commands.md
│   │   ├── desktop.sh
│   │   ├── display.sh
│   │   ├── distro.sh
│   │   ├── file_system.sh
│   │   ├── function.sh
│   │   ├── gpu.sh
│   │   ├── guard_clauses.md
│   │   ├── init_system.sh
│   │   ├── optical_drive.sh
│   │   └── package_manager.sh
│   ├── btrfs
│   │   ├── cow.md
│   │   ├── data_recovery.md
│   │   ├── maintenance.md
│   │   ├── preserve_home.md
│   │   ├── raid_setup.md
│   │   ├── subvolume_layouts.md
│   │   └── subvolumes.md
│   ├── bookmarks.md
│   ├── clock_format.md
│   ├── commands.md
│   ├── create_bootable_usb.md
│   ├── desktop_distro_combos.md
│   ├── filesystem_hierarchy.md
│   ├── packages.md
│   ├── partition_sizes.md
│   ├── setup.md
│   ├── snapshots.md
│   ├── swap_sizes.md
│   └── zram_vs_zswap.md
├── screenshots
│   ├── desktops
│   │   ├── fedora_gnome.png
│   │   ├── fedora_plasma.png
│   │   ├── linux_mint_cinnamon.png
│   │   └── linux_mint_xfce.png
│   ├── btrfs_compress-force_vs_compress.png
│   ├── waydroid_key_mapper.png
│   └── zram.png
├── scripts
│   ├── gaming
│   │   ├── setup_gaming.sh
│   │   └── tweak_games.sh
│   ├── git
│   │   ├── git_clone_repo.sh
│   │   ├── git_push_repo.sh
│   │   └── git_sync_repo.sh
│   ├── misc
│   │   ├── check_weather.sh
│   │   ├── chmod_scripts.sh
│   │   ├── generate_dnd_character.sh
│   │   ├── shellcheck_all.sh
│   │   └── update_readme.sh
│   ├── sync
│   │   ├── sync_backup_drives.sh
│   │   ├── sync_bashd.sh
│   │   └── sync_directory.sh
│   ├── system
│   │   ├── copy_pkg_configs.sh
│   │   ├── create_swapfile.sh
│   │   ├── export_smart_info.sh
│   │   ├── remove_snap.sh
│   │   ├── remove_swapfile.sh
│   │   └── setup_system.sh
│   ├── text
│   │   ├── dos2unix_converter.sh
│   │   ├── find_text.sh
│   │   ├── replace_text.sh
│   │   ├── snake_case_converter.sh
│   │   └── tab_space_converter.sh
│   └── tmp
│       └── tweaks.sh
└── readme.md

```
