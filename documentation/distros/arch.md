# Paccache

## Set paccache to only retain one past version of packages

sudo paccache -rk1

## Enables timer to discard unused packages weekly

sudo systemctl enable --now paccache.timer

# Checks for yay

if ! command -v yay > /dev/null 2>&1; then
  sudo pacman -S --needed --noconfirm git makepkg
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd ..
  rm -rf yay
fi

# Adds Chaotic AUR repository

# Checks for Chaotic AUR
if ! grep -q 'chaotic' /etc/pacman.conf; then
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key 3056513887B78AEB
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    sudo tee -a /etc/pacman.conf <<-'EOF'
    [chaotic-aur]
        Include = /etc/pacman.d/chaotic-mirrorlist

EOF
fi

# Microsoft Fonts

yay -S ttf-ms-win11-auto

# Update GRUB

sudo grub2-mkconfig
