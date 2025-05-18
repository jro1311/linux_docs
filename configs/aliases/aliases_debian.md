# Updates system
alias update='sudo nala upgrade && flatpak update'

# Removes unused packages and configuration files
alias clean='sudo nala clean && sudo nala autopurge && flatpak uninstall --unused'

# Simplified poweroff command
alias off='systemctl poweroff'

# Lists display server protocol
alias display='echo $XDG_SESSION_TYPE'

# Lists uuid of disks on the system
alias uuid='lsblk -o name,uuid'

# Checks for fstab errors
alias mountcheck='sudo findmnt --verify --verbose'

# Lists the SMART info of a disk
alias diskinfo='sudo smartctl -a'

# Shows detailed information about internal filesystem usage on btrfs
alias diskusage='sudo btrfs fi usa'

# View compression ratio for a directory or file
alias ratio='sudo compsize -x'

# btrfs scrub commands simplified (limits: --scrub-limits=)
alias scrub='sudo btrfs scrub start'
alias scrub-status='sudo btrfs scrub status'
alias scrub-cancel='sudo btrfs scrub cancel'
alias scrub-resume='sudo btrfs scrub resume'

# btrfs balance commands simplified (filters: -musage= -dusage=)
alias balance='sudo btrfs balance start'
alias balance-status='sudo btrfs balance status'
alias balance-cancel='sudo btrfs balance cancel'
alias balance-pause='sudo btrfs balance pause'
alias balance-resume='sudo btrfs balance resume'

# btrfs defrag command simplified
alias defrag='sudo btrfs fi defragment -vr'

# Simplified flatpak launch command
alias protontricks='flatpak run com.github.Matoking.protontricks'
alias protontricks-launch='flatpak run --command=protontricks-launch com.github.Matoking.protontricks'

# Enables MangoHud to run in all Vulkan games
#export MANGOHUD=1

# Launches goverlay with Adwaita dark theme
#alias goverlay='GTK_THEME=Adwaita:dark goverlay'

# Enables the user to run commands that are exclusive to the root user
export PATH=$PATH:/usr/sbin
