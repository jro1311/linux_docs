# Subvolume Layouts
## Single Distro (Recommended)
### /
- `@`

### /home
- `@home`

### /var/lib/flatpak
- `@flatpak`

### /var/lib/libvirt/images
- `@libvirt-images`

### /var/cache
- `@cache`

### /snapshots (skip if using Timeshift)
- `@snapshots`

## Multi Distro
### /
- `@arch`
- `@debian`
- `@fedora`

### /home
#### Separate (recommended when mixing different desktop environments)
- `@arch-home`
- `@debian-home`
- `@fedora-home

#### Joined (recommended only when using similar desktop environments)
- `@home`

### /var/lib/flatpak
- `@flatpak`

### /var/lib/libvirt/images
- `@arch-libvirt-images`
- `@debian-libvirt-images`
- `@fedora-libvirt-images`

### /var/cache
- `@arch-cache`
- `@debian-cache`
- `@fedora-cache`

### /snapshots (skip if using Timeshift)
- `@arch-snapshots`
- `@debian-snapshots`
- `@fedora-snapshots`
