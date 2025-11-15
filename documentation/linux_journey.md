# Linux Journey

## Timeline

- **June 8, 2024: Switched from Windows 10 to openSUSE Tumbleweed (KDE Plasma)**
- **September 7, 2024: Switched from openSUSE Tumbleweed to Linux Mint (Cinnamon), then Fedora Workstation**
    - Linux Mint packages are too old
- **September 8, 2024: Switched to openSUSE Tumbleweed (KDE Plasma)**
- **October 3, 2024: Switched to Fedora (KDE Plasma)**
    - openSUSE Tumbleweed update broke GRUB
- **October 4, 2024: Switched to openSUSE Tumbleweed (KDE Plasma)**
    - Long boot times on Fedora
    - Flatpak confusion
- **April 14, 2025: Switched to Fedora Silverblue**
- **April 18, 2025: Switched to Fedora Workstation**
    - Silverblue is too restrictive
    - Fstab errors on boot
    - Compression does not work everywhere
- **July 16, 2025: Switched from Fedora Workstation to CachyOS (KDE Plasma), then Fedora (KDE Plasma)**
    - LACT couldn't connect with service using system package on CachyOS
    - CachyOS is somewhat bloated
- **Current Distro: Fedora (KDE Plasma)**

## Distros

### Personal Ranking

- **S:** Fedora, Linux Mint
- **A:** openSUSE, Debian
- **B:** Fedora Atomic, Ubuntu, Void, Arch
- **C:** OpenMandriva

### Arch

- **Pros**
    - AUR
    - fast package manager
    - lightweight
    - minimal
    
- **Cons**
    - complicated installation process
    - less stable
    - requires a lot of manual setup
    - unconventional package manager syntax
    
### Debian

- **Pros**
    - backports
    - extremely stable
    - lightweight
    
- **Cons**
    - older packages
    - requires more manual setup

### Fedora

- **Pros**
    - decently stable
    - fast package manager
    - up-to-date
    
- **Cons**
    - btrfs snapshots require manual setup
    - unconventional default btrfs subvolume layout
    - selinux issues
    
### Fedora Atomic

- **Pros**
    - ostree rollbacks
    - stable
    - up-to-date
    
- **Cons**
    - restrictive
    - unintuitive compared to normal distros

### Linux Mint

- **Pros**
    - great for beginners
    - LTS support
    - stable
    
- **Cons**
    - no KDE Plasma edition
    - older packages
    
### OpenMandriva

- **Pros**
    - decent stable release (ROCK)
    - fast package manager
    - up-to-date (ROME)
    
- **Cons**
    - less stable on rolling release (ROME)
    - older packages on stable release (ROCK)
    - subpar btrfs support
    - worse rpm support compared to Fedora or even openSUSE 

### openSUSE

- **Pros**
    - automatic snapshots
    - reliable rolling release (Tumbleweed)
    - decent stable release (Leap)
    - up-to-date (Tumbleweed)
    - yast
    
- **Cons**
    - packman repo is often out of sync (Tumbleweed)
    - restrictive default firewall
    - slow package manager
    - worse rpm support compared to Fedora

### Ubuntu

- **Pros**
    - good for beginners
    - LTS support
    - stable
    
- **Cons**
    - snaps
    - unstable non-LTS versions

### Void

- **Pros**
    - fast package manager
    - lightweight
    - minimal
    - reliable rolling release
    - up-to-date
    
- **Cons**
    - no systemd
    - requires more manual setup
    - unconventional package manager syntax

## Desktop Environments

### Personal Ranking

- **S:** KDE Plasma, Customized GNOME
- **A:** Cinnamon, Xfce
- **B:** Vanilla GNOME, MATE, LXQt
- **C:** Budgie, Pantheon
- **D:** LXDE, Unity

### KDE Plasma

- **Pros**
    - extremly customizable
    - good Wayland support
    - polished look and feel
    
- **Cons**
    - less stable

### GNOME

- **Pros**
    - dynamic workspaces
    - good Wayland support
    - polished look and feel
    - stable
    
- **Cons**
    - not very customizable
    - unintuitive workflow

### Cinnamon

- **Pros**
    - decently customizable
    - polished look and feel
    - stable
    
- **Cons**
    - subpar Wayland support

### Xfce

- **Pros**
    - lightweight
    - stable
    - very customizable
    
- **Cons**
    - slower development
    - subpar Wayland support
    - ugly out of the box

### MATE

- **Pros**
    - decently customizable
    - lightweight
    - stable
    
- **Cons**
    - no Wayland support
    - slow development
    - ugly out of the box

### LXQt

- **Pros**
    - decently customizable
    - very lightweight
    
- **Cons**
    - barebones
    - less stable
    - subpar Wayland support
    - ugly out of the box

### Budgie

- **Pros**
    - stable
    
- **Cons**
    - no Wayland support
    - slow development

### Pantheon

- **Pros**
    - polished look and feel
    - stable
    
- **Cons**
    - not very customizable
    - slow development
    - subpar Wayland support

### LXDE

- **Pros**
    - extremely lightweight
    - stable
    
- **Cons**
    - barebones
    - deprecated in favor of LXQt
    - no Wayland support
    - ugly out of the box

### Unity

- **Pros**
    - lightweight
    - stable
    
- **Cons**
    - no Wayland support
    - outdated
    - slow development
