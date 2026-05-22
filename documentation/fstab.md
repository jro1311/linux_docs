# Fstab
## Mount Options
- **Check**

    ```bash
    mount | grep fs
    ```

- **Edit** 

    ```bash
    sudo nano /etc/fstab
    ```

- **universal**
    - noatime
        - reduce disk writes by not tracking access times
    - nofail (for secondary drives)
        - ignores errors when mounting during boot
- **btrfs**
    - compress=zstd:1
        - compress files using zstandard at the fastest setting of 1
    - autodefrag (for HDDs) 
        - automatically defragment disks as they are being used
- **ext4**
    - discard (for SSDs)
        - automatically discards blocks as they transition from used to free
- **f2fs**
    - compress_algorithm=zstd:1
        - compress files using zstandard at the fastest setting of 1
    - discard (for SSDs)
        - automatically discards blocks as they transition from used to free

## Example /etc/fstab

```
UUID=a74ffb72-feec-4cbe-8302-7011c0df1087               /                           btrfs   compress=zstd:1,noatime,subvol=@                                    0 0
UUID=d782e8cf-4da0-4758-857b-5f13eb2c6b0f               /boot                       ext4    defaults                                                            1 2
UUID=C427-CFE9                                          /boot/efi                   vfat    umask=0077,shortname=winnt                                          0 2
UUID=a74ffb72-feec-4cbe-8302-7011c0df1087               /home                       btrfs   compress=zstd:1,noatime,subvol=@home                                0 0
/dev/disk/by-uuid/353e031c-b0b2-41aa-9e0b-4cfaacf79ef3  /run/media/linux_backup1    btrfs   autodefrag,compress=zstd:1,noatime,nosuid,nodev,nofail,x-gvfs-show  0 0
/dev/disk/by-uuid/3cacb445-d462-4379-89b4-29d7a0b413e7  /run/media/linux_backup2    btrfs   autodefrag,compress=zstd:1,noatime,nosuid,nodev,nofail,x-gvfs-show  0 0
/dev/disk/by-id/usb-Verbatim_STORE_N_GO_12310000000066FF-0:0 /run/media/josh/usb_verbatim auto noatime,nosuid,nodev,nofail,x-gvfs-show,noauto 0 0
/dev/disk/by-id/usb-SanDisk_Cruzer_Glide_4C530000260408208335-0:0 /run/media/josh/usb_sandisk vfat noatime,nosuid,nodev,uid=1000,gid=1000,umask=0022,x-gvfs-show,noauto,nofail 0 0
```

## Notes
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
    - https://forums.unraid.net/bug-reports/prereleases/consider-using-compress-force-instead-of-compress-for-btrfs-compression-r2326/
    - https://www.reddit.com/r/btrfs/comments/mvbbbh/comment/gvbh9fq/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
    - https://www.reddit.com/r/btrfs/comments/1me3l5o/compressforce_compress_causes_very_high/
