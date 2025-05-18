# Installs nala (command-line frontend for apt)
sudo apt -y install nala

# Installs Microsoft fonts
sudo nala install -y ttf-mscorefonts-installer

# Installs Wine
sudo nala install -y wine-installer

# Unique aliases
## Updates system and flatpaks
alias update='sudo nala upgrade && flatpak update'

## Updates Cinnamon spices
alias cupdate='cinnamon-spice-updater --update-all'

## Removes unneeded dependencies and configuration files
alias clean='sudo nala clean && sudo nala autopurge && flatpak uninstall --unused'

# Software Manager
    - Menu>Preferences
        - Enable unverified flatpaks
