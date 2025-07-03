# Useful Commands

## Login Information

- Change username

```bash
sudo usermod -l new_username username
```

- Change password

```bash
passwd
```

- Change password of a user

```bash
passwd username - change password of a user
```

## Permissions

- Add write and execute permissions to a drive

```bash
sudo chmod ugo+wx /path/to/drive
```

## Themes

- Set consistent mouse cursor

```bash
sudo update-alternatives --config x-cursor-theme
```

## Text Editing

- Convert tabs to spaces with 4 spaces

```bash
expand -t 4 ./old_file.sh > ./new_file.sh - convert tabs to spaces with 4 spaces
```

- Convert spaces to tabs with 4 spaces

```bash
unexpand -t 4 ./old_file.sh > ./new_file.sh - convert tabs to spaces with 4 spaces
```
