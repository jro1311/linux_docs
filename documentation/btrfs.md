# BTRFS

## Example /etc/fstab

```
UUID=a74ffb72-feec-4cbe-8302-7011c0df1087               /                           btrfs   subvol=@,noatime,compress-force=zstd:1                              0 0
UUID=d782e8cf-4da0-4758-857b-5f13eb2c6b0f               /boot                       ext4    defaults                                                            1 2
UUID=C427-CFE9                                          /boot/efi                   vfat    umask=0077,shortname=winnt                                          0 2
UUID=a74ffb72-feec-4cbe-8302-7011c0df1087               /home                       btrfs   subvol=@home,noatime,compress-force=zstd:1                          0 0
/dev/disk/by-uuid/b01f756c-0e0f-42b9-972f-d2a59ce8422f  /run/media/linux_backup2    btrfs   autodefrag,compress=zstd:1,noatime,nosuid,nodev,nofail,x-gvfs-show  0 0
/dev/disk/by-uuid/25f0a759-8fc5-4379-933b-62e9518814c3  /run/media/linux_backup1    btrfs   autodefrag,compress=zstd:1,noatime,nosuid,nodev,nofail,x-gvfs-show  0 0

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

- **add compress-force=zstd:1 (for SSDs)**
    - force compress files using zstandard at the fastest setting of 1
- **add compress=zstd:1 (for HDDs and MMC storage)**
    - efficiently compress files using zstandard at the fastest setting of 1
- **add noatime**
    - reduce disk writes by not tracking access times
- **add autodefrag (for HDDs)**
    - automatically defragments disk as it's being used
- **add nofail (for secondary drives)**
    - ignores errors when mounting during boot

## Notes

- **compress**
    - more efficient
    - less fragmentation and number of extents
    - lesser space savings compared to compress-force
- **compress-force**
    - less efficient
    - more fragmentation and number of extents
    - greater space savings compared to compress 
- **Use compress-force instead of compress?**
    - https://forums.unraid.net/bug-reports/prereleases/consider-using-compress-force-instead-of-compress-for-btrfs-compression-r2326/
    - https://www.reddit.com/r/btrfs/comments/mvbbbh/comment/gvbh9fq/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
- **Use GRUB or Limine bootloader with CachyOS for easy bootable snapshots configuration**
