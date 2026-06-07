# Tweaks
## linux_docs
1. Remove old `linux_docs` folder, then clone git repo

    ```bash
    repo_url="https://github.com/jro1311/linux_docs.git"
    local_dir="$HOME/Documents/linux_docs"

    if ! command -v git >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y git
    fi

    rm -rf "$local_dir"
    git clone "$repo_url" "$local_dir"
    ```
    
2. Change directory, make all scripts executable, then run `tweaks.sh`

    ```bash
    scripts="$HOME/Documents/linux_docs/scripts"
    
    chmod +x "$scripts/misc/chmod_scripts.sh"
    "$scripts/misc/chmod_scripts.sh" && "$scripts/tmp/tweaks.sh"
    ```
    
## Text Editors

```bash
# Configure editors to use tabs instead of spaces
sed -i 's/"tabstospaces": true/"tabstospaces": false/' "$HOME/.config/micro/settings.json"
sed -i 's/set tabstospaces/#set tabstospaces/' "$HOME/.config/nano/nanorc"
sudo sed -i 's/set tabstospaces/#set tabstospaces/' /etc/nanorc
```
