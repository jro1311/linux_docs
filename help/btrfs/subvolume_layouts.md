# Subvolume Layouts
## Single Distro (Recommended)
- `@` mounted as `/`
- `@home` mounted as `/home`
- `@flatpak` mounted as `/var/lib/flatpak`
- `@libvirt-images` mounted as `/var/lib/libvirt/images`
- `@log` mounted as `/var/log`
- `@cache` mounted as `/var/cache`
- `@snapshots` mounted as `/snapshots`

## Multi Distro
### /
- `@arch` mounted as `/` when booted into Arch
- `@debian` mounted as `/` when booted into Debian
- `@fedora` mounted as `/` when booted into Fedora

### /home
#### Separate (Recommended when using mixing desktop environments)
- `@arch-home` mounted as `/home` when booted into Arch
- `@debian-home` mounted as `/home` when booted into Debian
- `@fedora-home` mounted as `/home` when booted into Fedora

#### Joined (Recommended ONLY when using similar desktop environments)
- `@home` mounted as `/home`

### /var/lib/flatpak
- `@flatpak` mounted as `/var/lib/flatpak`

### /var/lib/libvirt/images
- `@arch-libvirt-images` mounted as `/var/lib/libvirt/images` when booted into Arch
- `@debian-libvirt-images` mounted as `/var/lib/libvirt/images` when booted into Debian
- `@fedora-libvirt-images` mounted as `/var/lib/libvirt/images` when booted into Fedora

### /var/log
- `@arch-log` mounted as `/var/log` when booted into Arch
- `@debian-log` mounted as `/var/log` when booted into Debian
- `@fedora-log` mounted as `/var/log` when booted into Fedora

### /var/cache
- `@arch-cache` mounted as `/var/cache` when booted into Arch
- `@debian-cache` mounted as `/var/cache` when booted into Debian
- `@fedora-cache` mounted as `/var/cache` when booted into Fedora

### /snapshots
- `@arch-snapshots` mounted as `/snapshots` when booted into Arch
- `@debian-snapshots` mounted as `/snapshots` when booted into Debian
- `@fedora-snapshots` mounted as `/snapshots` when booted into Fedora
