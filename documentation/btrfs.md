# BTRFS

## Example /etc/fstab

```
UUID=273db107-e898-46e8-a8f2-e9923cfc7c51  /                         btrfs  subvol=/@,compress-force=zstd:1,noatime                   0 0
UUID=2bc9864c-b3e6-4615-90a5-ceff6a6a89e0  /boot                     ext4   defaults                                            1 2
UUID=C17F-2BED                             /boot/efi                 vfat   utf8                                                0 2
UUID=c45fdeeb-3673-4700-b9b7-107ee6abc4fb  /home                     btrfs  subvol=/@home,compress-force=zstd:1,noatime               0 0
UUID=cfafbe37-a73d-4dcd-b04c-12fa52233bce  /run/media/linux_backup   btrfs  autodefrag,compress-force=zstd:1,noatime,nofail           0 0
UUID=95b1038e-c58d-4e3f-94c0-ce15676ec81a  /run/media/linux_backup2  btrfs  autodefrag,compress-force=zstd:1,noatime,nofail           0 0
```

## Mount Options

- **Check** 

```bash
mount | grep btrfs
```

- **Edit** 

```bash
sudo nano /etc/fstab
```

- **add compress-force=zstd:1**
    - force compress files using zstandard at the fastest setting of 1
- **add noatime**
    - reduce disk writes by not tracking access times
- **add autodefrag for HDDs**
    - automatically defragments disk as it's being used
- **add nofail for secondary drives**
    - ignores errors when mounting during boot

## Notes

- **use compress-force instead of compress**
    - https://forums.unraid.net/bug-reports/prereleases/consider-using-compress-force-instead-of-compress-for-btrfs-compression-r2326/
    - https://www.reddit.com/r/btrfs/comments/mvbbbh/comment/gvbh9fq/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
- **Use GRUB or Limine bootloader with CachyOS for easy bootable snapshots configuration**
