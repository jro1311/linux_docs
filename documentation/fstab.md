# Fstab
## Universal Mount Options
- `noatime`
    - reduce disk writes by not updating file access times
- `nofail` (for secondary drives)
    - ignore mount errors at boot
    - system continues booting normally
- `noauto` (for secondary drives)
    - only mount manually
    - never mount automatically at boot or during `mount -a`

## Filesystem-Specific Mount Options
### BTRFS
- `compress=zstd:1`
    - compress files using zstd at level 1 (fast)
- `autodefrag` (for HDDs)
    - incrementally defragment small random writes
    - no effect on large files

### EXT4
- `discard` (not recommended) (for SSDs)
    - issue TRIM commands continuously as blocks are freed

### F2FS
- `compress_algorithm=zstd:1`
    - compress files using zstd at level 1 (fast)
- `discard` (not recommended) (for SSDs) 
    - issue TRIM commands continuously as blocks are freed
    
- **Check**

    ```bash
    findmnt
    ```

- **Edit (Temporarily)**
    
    ```bash
    sudo mount -o remount,mount_options /
    ```
    
- **Edit (Permanently)** 

    ```bash
    sudo "$EDITOR" /etc/fstab
    ```

## Example /etc/fstab

```
UUID=a74ffb72-feec-4cbe-8302-7011c0df1087                       /                                   btrfs   noatime,compress=zstd:1,subvol=@                                    0 0
UUID=d782e8cf-4da0-4758-857b-5f13eb2c6b0f                       /boot                               ext4    defaults                                                            1 2
UUID=C427-CFE9                                                  /boot/efi                           vfat    umask=0077,shortname=winnt                                          0 2
UUID=a74ffb72-feec-4cbe-8302-7011c0df1087                       /home                               btrfs   noatime,compress=zstd:1,subvol=@home                                0 0
UUID=a74ffb72-feec-4cbe-8302-7011c0df1087                       /var/lib/flatpak                    btrfs   noatime,compress=zstd:1,subvol=@flatpak                             0 0
UUID=a74ffb72-feec-4cbe-8302-7011c0df1087                       /var/lib/libvirt/images             btrfs   noatime,compress=zstd:1,subvol=@libvirt-images                      0 0
UUID=a74ffb72-feec-4cbe-8302-7011c0df1087                       /var/cache                          btrfs   noatime,compress=zstd:1,subvol=@cache                               0 0
UUID=a74ffb72-feec-4cbe-8302-7011c0df1087                       /var/log                            btrfs   noatime,compress=zstd:1,subvol=@log                                 0 0
UUID=353e031c-b0b2-41aa-9e0b-4cfaacf79ef3                       /run/media/linux_backup1            btrfs   noatime,compress=zstd:1,autodefrag,nosuid,nodev,nofail,x-gvfs-show  0 0
UUID=3cacb445-d462-4379-89b4-29d7a0b413e7                       /run/media/linux_backup2            btrfs   noatime,compress=zstd:1,autodefrag,nosuid,nodev,nofail,x-gvfs-show  0 0
/dev/disk/by-id/usb-Verbatim_STORE_N_GO_12310000000066FF-0:0    /run/media/josh/usb_verbatim        auto    noatime,nosuid,nodev,nofail,x-gvfs-show,noauto                      0 0
```

## BTRFS Notes
- **compress**
    - more efficient
    - less fragmentation
    - lower number of extents
    - lower metadata usage
    - potentially lower space savings compared to compress-force
- **compress-force**
    - less efficient
    - more fragmentation 
    - higher number of extents
    - higher metadata usage
    - potentially higher space savings compared to compress
    
### References
- https://forums.unraid.net/bug-reports/prereleases/consider-using-compress-force-instead-of-compress-for-btrfs-compression-r2326/
- https://www.reddit.com/r/btrfs/comments/mvbbbh/comment/gvbh9fq/
- https://www.reddit.com/r/btrfs/comments/1me3l5o/compressforce_compress_causes_very_high/
