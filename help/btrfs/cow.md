# Enable/Disable Copy-On-Write (COW) on Files or Directories

- **Check COW Status**

    ```bash
    lsattr ./file
    lsattr -d dir
    ```

- **Disable COW**

    ```bash
    sudo chattr +C ./file
    ```
    
- Recursively

    ```bash
    sudo chattr -R +C ./directory
    ```
    
- **Enable COW**
    
    ```bash
    sudo chattr -C ./file
    ```
    
- Recursively

    ```bash
    sudo chattr -R -C ./directory
    ```
