# Scripts

## Enable
alias enable-chaotic-aur='$HOME/Documents/linux_docs/scripts/enable/enable_chaotic_aur.sh'
alias enable-debian-backports='$HOME/Documents/linux_docs/scripts/enable/enable_debian_backports.sh'
alias enable-permanent-mac-address='$HOME/Documents/linux_docs/scripts/enable/enable_permanent_mac_address.sh'
alias enable-xorg-vrr='$HOME/Documents/linux_docs/scripts/enable/enable_xorg_vrr.sh'
alias enable-zswap='$HOME/Documents/linux_docs/scripts/enable/enable_zswap.sh'

## Remove
alias remove-snap='$HOME/Documents/linux_docs/scripts/remove/remove_snap.sh'
alias remove-swapfile='$HOME/Documents/linux_docs/scripts/remove/remove_swapfile.sh'

## Setup
alias install-gaming-meta='$HOME/Documents/linux_docs/scripts/setup/install_gaming_meta.sh'
alias install-codecs='$HOME/Documents/linux_docs/scripts/setup/install_codecs.sh'
alias universal-distro-setup='$HOME/Documents/linux_docs/scripts/setup/universal_distro_setup.sh'

## Sync
alias sync-backup='$HOME/Documents/linux_docs/scripts/sync/sync_backup.sh'
alias sync-bashrc-configs='$HOME/Documents/linux_docs/scripts/sync/sync_bashrc_configs.sh'
alias sync-custom='$HOME/Documents/linux_docs/scripts/sync/sync_custom.sh'
alias sync-linux-docs='$HOME/Documents/linux_docs/scripts/sync/sync_linux_docs.sh'

## Tools
alias create-swapfile='$HOME/Documents/linux_docs/scripts/tools/create_swapfile.sh'
alias dos2unix-converter='$HOME/Documents/linux_docs/scripts/tools/dos2unix_converter.sh'
alias export-smart-info='$HOME/Documents/linux_docs/scripts/tools/export_smart_info.sh'
alias replace-text='$HOME/Documents/linux_docs/scripts/tools/replace_text.sh'
alias snake-case-converter='$HOME/Documents/linux_docs/scripts/tools/snake_case_converter.sh'
alias tab-space-converter='$HOME/Documents/linux_docs/tools/scripts/tab_space_converter.sh'

alias chmod-scripts='chmod +x $HOME/Documents/linux_docs/scripts/chmod_scripts.sh && $HOME/Documents/linux_docs/scripts/chmod_scripts.sh'
alias git-clone-repo='$HOME/Documents/linux_docs/scripts/git_clone_repo.sh'
alias shellcheck-scripts='$HOME/Documents/linux_docs/scripts/shellcheck_scripts.sh'

# BTRFS
alias balance='sudo btrfs balance start'
alias balance-cancel='sudo btrfs balance cancel'
alias balance-pause='sudo btrfs balance pause'
alias balance-resume='sudo btrfs balance resume'
alias balance-status='sudo btrfs balance status'
alias defrag='sudo btrfs filesystem defragment -rv'
alias disable-cow='sudo chattr +C'
alias disable-cow-recursive='sudo chattr -R +C'
alias enable-cow='sudo chattr -C'
alias enable-cow-recursive='sudo chattr -R -C'
alias fsusage='sudo btrfs filesystem usage'
alias ratio='sudo compsize -x'
alias scrub='sudo btrfs scrub start'
alias scrub-cancel='sudo btrfs scrub cancel'
alias scrub-resume='sudo btrfs scrub resume'
alias scrub-status='sudo btrfs scrub status'

# Packages
if ! command -v protontricks >/dev/null 2>&1; then
    alias protontricks='flatpak run com.github.Matoking.protontricks'
    alias protontricks-launch='flatpak run --command=protontricks-launch com.github.Matoking.protontricks'
fi
alias waystop='waydroid session stop'

# Other
alias desktop='echo $XDG_CURRENT_DESKTOP'
alias diskinfo='sudo smartctl -a'
alias mountcheck='sudo findmnt --verify --verbose'
alias sbash='source $HOME/.bashrc'
alias session='echo $XDG_SESSION_TYPE'
alias uuid='lsblk -o name,uuid'
