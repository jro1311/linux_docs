# BTRFS Maintenance
## Scrub
- Verifies checksums of all data and metadata
- Repairs corruption if redundant copies exist (RAID1/10/5/6, DUP)
- Does not fix logical metadata inconsistencies

## Balance
- Redistributes block groups to improve space usage
- Useful in multi-device setups or after device changes
- Does not reclaim deleted space or defragment files

## Defragment
- Rewrites fragmented extents to improve read performance
- Not to be confused with `autodefrag`

## Send/Receive
- Efficiently replicates snapshots between filesystems
- Ideal for backups and incremental transfers

## References
- https://btrfs.readthedocs.io/en/latest/Scrub.html
- https://btrfs.readthedocs.io/en/latest/btrfs-balance.html
- https://btrfs.readthedocs.io/en/latest/btrfs-filesystem.html#man-filesystem-cmd-defragment
- https://btrfs.readthedocs.io/en/latest/btrfs-send.html
