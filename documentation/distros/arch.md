# Adds Chaotic AUR repository
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
echo "[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf

# Installs AUR helper yay if it is not already installed
if ! command -v yay > /dev/null 2>&1; then
  echo "yay is not installed. Installing yay..."
  sudo pacman -S --needed --noconfirm git makepkg
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd ..
  rm -rf yay
else
  echo "yay is already installed"
fi

# Installs Microsoft fonts
yay -S ttf-ms-win11-auto

# Adds current user to wheel group if they are not already
sudo usermod -aG wheel $USER

# Installs flatpak
sudo pacman -Syu --needed --noconfirm flatpak

# Adds Flathub repository if it doesn't already exist
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Set paccache to only retain one past version of packages
sudo paccache -rk1

# Enables timer to discard unused packages weekly
sudo systemctl enable --now paccache.timer

# Unique aliases
## Updates system and flatpaks
alias update='yay -Syu && flatpak update'

## Lists running processes on the system which continue to use deleted files after an upgrade or removal of packages
alias check='pacman -Qkk'

## Lists orphaned packages
alias orphan='pacman -Qtd'

## Removes orphaned packages
alias clean='sudo pacman -Qdtq | pacman -Rns - && flatpak uninstall --unused'

## Clears the package cache
alias clear='sudo pacman -Scc'
