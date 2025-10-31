# Linux Resource Usage

## Methodology

- Tested in a live session on real hardware
- Waited 5-10 minutes for system to settle before data was recorded
- Network was disconnected before CPU and RAM usage was recorded
- Idle CPU Tasks and RAM usage was measured with `top`
    - Cached RAM was not taken into account when ranking
- VRAM usage was measured with `btop`

## Fedora 43

### Desktop Environment Idle CPU Tasks (Ryzen 5 5600)

```
- GNOME (Wayland)       ~410
- KDE Plasma (Wayland)  ~395
- Cinnamon (X11)        ~380
- MATE (X11)            ~365
- Xfce (X11)            ~375
- LXQt (X11)            ~350
- Sway (Wayland)        ~365

1. LXQt (X11)           +5 pts
2. MATE (X11)           +4 pts
2. Sway (Wayland)       +4 pts
3. Xfce (X11)           +3 pts
4. Cinnamon (X11)       +2 pts
5. KDE Plasma (Wayland) +1 pts
6. GNOME (Wayland)      0 pts
```

## Desktop Environment Idle RAM Usage (16 GiB RAM)

```
- GNOME (Wayland)       ~1700 MiB (excluding ~3950 MiB buff/cache)
- KDE Plasma (Wayland)  ~2550 MiB (excluding ~4100 MiB buff/cache)
- Cinnamon (X11)        ~1650 MiB (excluding ~1200 MiB buff/cache)
- MATE (X11)            ~1300 MiB (excluding ~950 MiB buff/cache)
- Xfce (X11)            ~1400 MiB (excluding ~2700 MiB buff/cache)
- LXQt (X11)            ~1250 MiB (excluding ~2750 MiB buff/cache)
- Sway (Wayland)        ~1250 MiB (excluding ~950 MiB buff/cache)

1. LXQt (X11)           +5 pts
1. Sway (Wayland)       +5 pts
2. MATE (X11)           +4 pts
3. Xfce (X11)           +3 pts
4. Cinnamon (X11)       +2 pts
5. GNOME (Wayland)      +1 pts
6. KDE Plasma (Wayland) 0 pts
```

## Desktop Environment Idle VRAM Usage (8 GiB VRAM)

```
- GNOME (Wayland)       ~400 MiB
- KDE Plasma (Wayland)  ~620 MiB
- Cinnamon (X11)        ~300 MiB
- MATE (X11)            ~180 MiB
- Xfce (X11)            ~150 MiB
- LXQt (X11)            ~150 MiB
- Sway (Wayland)        ~110 MiB

1. Sway (Wayland)        +5 pts
2. Xfce (X11)            +4 pts
2. LXQt (X11)            +4 pts
3. MATE (X11)            +3 pts
4. Cinnamon (X11)        +2 pts
5. GNOME (Wayland)       +1 pts
6. KDE Plasma (Wayland)  0 pts
```

## Total Score

```
1. LXQt (X11)           14 pts
1. Sway (Wayland)       14 pts
2. MATE (X11)           11 pts
3. Xfce (X11)           10 pts
4. Cinnamon (X11)       6 pts
5. GNOME (Wayland)      2 pts
6. KDE Plasma (Wayland) 1 pts
```

# Linux Mint 22.x & LMDE 7

### Desktop Environment Idle CPU Tasks (Ryzen 5 5600)

```
- LMDE Cinnamon (X11)   ~355
- Cinnamon (X11)        ~345
- MATE (X11)            ~340
- Xfce (X11)            ~335

1. Xfce (X11)           +3 pts
2. MATE (X11)           +2 pts
3. Cinnamon (X11)       +1 pts
4. LMDE Cinnamon (X11)  0 pts
```

## Desktop Environment Idle RAM Usage (16 GiB RAM)

```
- LMDE Cinnamon (X11)   ~1400 MiB used (excluding ~1050 MiB buff/cache)
- Cinnamon (X11)        ~1600 MiB used (excluding ~3850 MiB buff/cache)
- MATE (X11)            ~1450 MiB used (excluding ~4150 MiB buff/cache)
- Xfce (X11)            ~1400 MiB used (excluding ~3750 MiB buff/cache)

1. LMDE Cinnamon (X11)  +2 pts
1. Xfce (X11)           +2 pts
2. MATE (X11)           +1 pts
3. Cinnamon (X11)       0 pts
```

## Desktop Environment Idle VRAM Usage (8 GiB VRAM)

```
- LMDE Cinnamon (X11)   ~300 MiB
- Cinnamon (X11)        ~300 MiB
- MATE (X11)            ~180 MiB
- Xfce (X11)            ~250 MiB

1. MATE (X11)           +2 pts
2. Xfce (X11)           +1 pts
3. Cinnamon (X11)       0 pts
3. LMDE Cinnamon (X11)  0 pts
```

## Total Score

```
1. Xfce (X11)           6 pts
2. MATE (X11)           5 pts
3. LMDE Cinnamon (X11)  2 pts
4. Cinnamon (X11)       1 pts
```
