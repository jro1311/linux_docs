#!/usr/bin/env bash
# shellcheck shell=bash

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

# General
alias clean-git='git gc --aggressive --prune=now'
alias cmdline='cat /proc/cmdline'
alias cursor-sync='sudo update-alternatives --config x-cursor-theme'
alias desktop='echo $XDG_CURRENT_DESKTOP'
alias diskinfo='sudo smartctl -a'
alias mountcheck='sudo findmnt --verify --verbose'
alias path='echo "$PATH" | tr ":" "\n"'
alias sbash='. $HOME/.bashrc'
alias tbash='time bash -i -c exit'
alias session='echo $XDG_SESSION_TYPE'
alias uuid='lsblk -o name,uuid'
alias vm-parameters='sudo grep -R . /proc/sys/vm'
alias waystop='waydroid session stop'
alias zswap-info='sudo grep -r . /sys/kernel/debug/zswap'
alias zswap-parameters='grep -R . /sys/module/zswap/parameters'
