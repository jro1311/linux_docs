# Paccache

## Set paccache to only retain one past version of packages

sudo paccache -rk1

## Enables timer to discard unused packages weekly

sudo systemctl enable --now paccache.timer

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

# Adds Chaotic AUR repository

sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
echo "[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf

# Microsoft Fonts

yay -S ttf-ms-win11-auto
