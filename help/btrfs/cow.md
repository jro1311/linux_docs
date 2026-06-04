# Enable/Disable Copy-On-Write (COW) on Files or Directories
## Check COW Status
- `C` attribute = COW disabled (NOCOW)
- No `C` attribute = COW enabled
    - Existing files may still be NOCOW if created earlier

```bash
lsattr ./file
lsattr -d ./dir
```

## Disable COW (NOCOW)

```bash
sudo chattr +C ./file
```
    
### Recursive (Not Recommended)

```bash
sudo chattr -R +C ./dir
```

- This only affects newly created files
- Existing files remain COW unless rewritten
- Recursive NOCOW creates mixed COW/NOCOW state by flipping attributes without rewriting extents
    
## Enable COW
    
```bash
sudo chattr -C ./file
```
    
### Recursive (Not Recommended)

```bash
sudo chattr -R -C ./dir
```

- Removing the `C` attribute does not convert existing files back to COW
- Only new writes will use COW
- Recursive COW is discouraged for the same mixed‑state reasons as recursive NOCOW
