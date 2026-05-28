#!/usr/bin/env bash
# shellcheck shell=bash

# Scripts
alias check-weather='check_weather'
alias chmod-scripts='chmod_scripts'
alias copy-pkg-configs='copy_pkg_configs'
alias create-swapfile='create_swapfile'
alias dos2unix-converter='dos2unix_converter'
alias export-smart-info='export_smart_info'
alias find-text='find_text'
alias generate-dnd-character='generate_dnd_character'
alias git-clone-repo='git_clone_repo'
alias git-push-repo='git_push_repo'
alias git-sync-repo='git_sync_repo'
alias remove-snap='remove_snap'
alias remove-swapfile='remove_swapfile'
alias replace-text='replace_text'
alias setup-gaming='setup_gaming'
alias setup-system='setup_system'
alias shellcheck-all='shellcheck_all'
alias snake-case-converter='snake_case_converter'
alias sync-backup-drives='sync_backup_drives'
alias sync-bashd='sync_bashd'
alias sync-directory='sync_directory'
alias tab-space-converter='tab_space_converter'
alias tweak-games='tweak_games'
alias update-readme='update_readme'

# BTRFS
alias balance='sudo btrfs balance start'
alias balance-cancel='sudo btrfs balance cancel'
alias balance-pause='sudo btrfs balance pause'
alias balance-resume='sudo btrfs balance resume'
alias balance-status='sudo btrfs balance status'
alias defrag='sudo btrfs filesystem defragment -rv'
alias fsusage='sudo btrfs filesystem usage'
alias ratio='sudo compsize -x'
alias scrub='sudo btrfs scrub start'
alias scrub-cancel='sudo btrfs scrub cancel'
alias scrub-resume='sudo btrfs scrub resume'
alias scrub-status='sudo btrfs scrub status'
alias subvolume-list='sudo btrfs subvolume list /'

# Shell Utilities
alias mv-safe='mv_safe'
alias cp-safe='cp_safe'
alias rm-safe='rm_safe'

alias ls='ls -A --color=auto --group-directories-first'
alias lc='\ls -A1 --color=auto --group-directories-first'
alias ll='\ls -Alh --color=auto --group-directories-first'

alias cmdline='cat /proc/cmdline'
alias desktop='echo $XDG_CURRENT_DESKTOP'
alias session='echo $XDG_SESSION_TYPE'
alias path='echo "$PATH" | tr ":" "\n"'

alias sbash='. $HOME/.bashrc'
alias tbash='time bash -i -c exit'

alias diskinfo='sudo smartctl -a'
alias mountcheck='sudo findmnt --verify --verbose'
alias uuid='lsblk -o name,uuid'

alias vm-parameters='grep -R . /proc/sys/vm 2>/dev/null'
alias zswap-info='sudo grep -r . /sys/kernel/debug/zswap'
alias zswap-parameters='grep -R . /sys/module/zswap/parameters'

alias waystop='waydroid session stop'
