# Scrub
- Running a btrfs scrub can help to
    - Detect and repair data corruption caused by hardware failures or software bugs
    - Identify and fix metadata inconsistencies that can cause file system errors
    - Ensure the integrity of the data on the file system
   
# Balance
- When you run a btrfs balance, it reorganizes the data and metadata blocks on the disk to ensure that the file system is using the available space efficiently. This can help to
    - Reclaim space from deleted files and metadata
    - Reduce fragmentation, which can lead to out-of-space errors
    - Improve overall file system performance
    
- When running a btrfs balance, the 'du' and 'mu' options are used to filter the balance operation based on the usage of data and metadata blocks, respectively
    - The 'du' option filters the balance operation based on the usage of data blocks. 
        - It takes a percentage value as an argument, and only blocks with usage below that percentage will be considered for balancing. For example, 'du=10' would only balance data blocks that are less than 10% used
        
    - The 'mu' option filters the balance operation based on the usage of metadata blocks. 
        - It also takes a percentage value as an argument, and only blocks with usage below that percentage will be considered for balancing. For example, 'mu=10' would only balance metadata blocks that are less than 10% used
        
    - These options can be used to balance only the most underutilized blocks, which can help to improve the overall efficiency of the file system
