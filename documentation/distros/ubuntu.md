# Unique aliases
# Updates system, flatpaks, and snaps
alias update='sudo nala upgrade && flatpak update && sudo snap refresh'

# Removes unneeded dependencies and configuration files
alias clean='sudo nala clean && sudo nala autopurge && flatpak uninstall --unused'
