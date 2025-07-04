# Arch

## AUR

- **helpers**
    - paru
    - yay
- **packages**
    - btrfsmaintenance
        - systemd timers and scripts for btrfs maintenance
    - heroic-games-launcher-bin
        - game launcher
    - librewolf-bin
        - web browser
    - linux-lts
        - lts kernel
    - nano-syntax-highlighting
        - syntax highlighting in nano
    - ttf-ms-win11-auto
        - microsoft fonts
    - vesktop
        - custom discord client
- **repositories**
    - chaotic-aur

## Paccache

- **Removes all cached versions of packages except the latest and one prior version**

```bash
sudo paccache -rk1
```

- **Enables timer to discard unused packages weekly**

```bash
sudo systemctl enable --now paccache.timer
```

# Debian

## Codecs

```bash
chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_debian_install.sh"
"$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_debian_install.sh"
```

## Distros

### Linux Mint

- **Software Manager**
    - Menu>Preferences
    - Enable `Show unverified Flatpaks`
        
## Packages

- **nala**
    - apt frontend
- **ttf-mscorefonts-installer**
    - microsoft fonts installer

# Fedora

## Codecs

```bash
chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_fedora_install.sh"
"$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_fedora_install.sh"
```

## Packages

```bash
sudo dnf install -y https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
```

# OpenMandriva

## Codecs

```bash
chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_openmandriva_install.sh"
"$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_openmandriva_install.sh"
```

# openSUSE

## Codecs 

```bash
sudo zypper in -y opi && opi codecs
```

## Firewall Exceptions

```bash
sudo firewall-cmd --add-interface=wlp8s0 --zone=home --permanent
sudo firewall-cmd --set-default-zone=home --permanent
sudo firewall-cmd --zone=home --add-service=bittorrent-lsd --permanent
sudo firewall-cmd --zone=home --add-service=dhcp --permanent
sudo firewall-cmd --zone=home --add-service=dhcpv6 --permanent
sudo firewall-cmd --zone=home --add-service=dhcpv6-client --permanent
sudo firewall-cmd --zone=home --add-service=dns --permanent
sudo firewall-cmd --zone=home --add-service=dns-over-quic --permanent
sudo firewall-cmd --zone=home --add-service=dns-over-tls --permanent
sudo firewall-cmd --zone=home --add-service=http --permanent
sudo firewall-cmd --zone=home --add-service=http3 --permanent
sudo firewall-cmd --zone=home --add-service=mdns --permanent
sudo firewall-cmd --zone=home --add-service=samba-client --permanent
sudo firewall-cmd --zone=home --add-service=slp --permanent
sudo firewall-cmd --zone=home --add-service=spotify-sync --permanent
sudo firewall-cmd --zone=home --add-service=ssh --permanent
sudo firewall-cmd --zone=home --add-service=terraria --permanent
sudo firewall-cmd --zone=home --add-service=transmission-client --permanent
sudo firewall-cmd --zone=home --add-port=161-162/tcp --permanent
sudo firewall-cmd --zone=home --add-port=9100/tcp --permanent
sudo firewall-cmd --zone=home --add-port=161-162/udp --permanent
sudo firewall-cmd --zone=home --add-port=9100/udp --permanent
sudo firewall-cmd --reload
```

## HP Printer Setup

1. Install the `hplip` package

```bash
sudo zypper in -y hplip
```

2. Launch `HP Setup`
3. Add the local IP address of the printer to manual discovery 
    - e.g., 192.168.0.180

## Packages

- **fetchmsttfonts**
    - microsoft fonts installer

# Void

## Codecs

```bash
chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_void_install.sh"
"$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_void_install.sh"
```

## zRAM

```bash
sudo xbps-install -y zramen
sudo zramen make -a zstd -s 100
sudo cp -v "$HOME/Documents/linux_docs/configs/packages/99-zram.conf" /etc/sysctl.d/
sudo mkdir -pv /etc/sysctl.d
sudo sysctl -p /etc/sysctl.d/99-zram.conf
```
