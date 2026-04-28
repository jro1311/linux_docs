# Maintenance

- **Scrub**
    - https://btrfs.readthedocs.io/en/latest/Scrub.html
    - Verifies checksums of all data and metadata, detects corruption, and repairs it if redundant copies are available
    - Ensures data integrity but does not fix logical metadata inconsistencies
    
- **Balance** 
    - https://btrfs.readthedocs.io/en/latest/btrfs-balance.html
    - Redistributes block groups across devices to improve space usage and prevent allocation problems
    - Useful in multi-device setups, but does not reclaim deleted space or defragment files
