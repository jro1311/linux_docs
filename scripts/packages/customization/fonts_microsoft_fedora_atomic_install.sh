#!/bin/bash

# Disclaimer: I did not write this script. All credit goes to solidc0re.
# Source: https://codeberg.org/solidc0re/atomic-fedora-mscorefonts

VERSION="1.0"

# Inspired by Daniel (aka pluto): https://discussion.fedoraproject.org/t/ms-core-fonts-on-silverblue/1916/5

# Part 1

# Check if already in a toolbox
if [ -f /run/.containerenv ]; then
    echo "This script should not be run inside a toolbox. Exiting."
    exit 1
fi

# Define script dir as the current directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Create install dir
INSTALL_DIR="$SCRIPT_DIR/mscorefonts_tmp"
mkdir -p "$INSTALL_DIR"

# Create mscorefonts-part2.sh
cat << 'EOF' > "$INSTALL_DIR/mscorefonts-part2.sh"
#!/bin/bash

# Part 2

# Install Make and GCC
echo "Installing required packages. This will may a while..."
sudo dnf -y install make gcc &>/dev/null

# Download and compile cabextract
wget --timeout=60 --max-redirect=20 https://www.cabextract.org.uk/cabextract-1.11.tar.gz &>/dev/null
tar -zxf cabextract-1.11.tar.gz &>/dev/null
cd cabextract-1.11
./configure --prefix=/usr/local &>/dev/null && make &>/dev/null
sudo make install &>/dev/null

# Download and extract fonts
_sfpath="http://downloads.sourceforge.net/corefonts"
fonts=(
    $_sfpath/andale32.exe
    $_sfpath/arial32.exe
    $_sfpath/arialb32.exe
    $_sfpath/comic32.exe
    $_sfpath/courie32.exe
    $_sfpath/georgi32.exe
    $_sfpath/impact32.exe
    $_sfpath/times32.exe
    $_sfpath/trebuc32.exe
    $_sfpath/verdan32.exe
    $_sfpath/webdin32.exe
    )

mkdir fonts 2>/dev/null

echo "Downloading and extracting fonts..."

for i in "${fonts[@]}"
do
    wget $i &>/dev/null
    cabextract $(basename $i) -d fonts &>/dev/null
done

# Install for user
echo "Installing fonts for user..."
mkdir $HOME/.local/share/fonts 2>/dev/null
mkdir $HOME/.local/share/fonts/mscorefonts 2>/dev/null
cp fonts/*.ttf fonts/*.TTF $HOME/.local/share/fonts/mscorefonts/ 2>/dev/null
EOF

# Create mscorefonts-part3.sh
cat << 'EOF' > "$INSTALL_DIR/mscorefonts-part3.sh"

#!/bin/bash

# Part 3

# Grab variables
SCRIPT_DIR="$1"
INSTALL_DIR="$2"

# Install system-wide
echo "Installing fonts system-wide (requires sudo)..."
sudo mkdir /usr/local/share/fonts/ 2>/dev/null
sudo mkdir /usr/local/share/fonts/mscorefonts/ 2>/dev/null
sudo cp $HOME/.local/share/fonts/mscorefonts/*.ttf $HOME/.local/share/fonts/mscorefonts/*.TTF /usr/local/share/fonts/mscorefonts/ 2>/dev/null

# Refresh font cache
echo "Refreshing font cache..."
fc-cache -f >/dev/null

# Cleanup
echo "Cleaning up..."
toolbox rm -f solidcore-tmp
cd "$SCRIPT_DIR"
rm -rf cabextract-1.11.tar.gz cabextract-1.11
rm -rf "$INSTALL_DIR"
echo "All done."
EOF

# Make part 2 and 3 executable
chmod +x "$INSTALL_DIR/mscorefonts-part2.sh"
chmod +x "$INSTALL_DIR/mscorefonts-part3.sh"

# Create a trap to run part 3 and passing along the needed variables after toolbox exit
trap "bash $INSTALL_DIR/mscorefonts-part3.sh \"$SCRIPT_DIR\" \"$INSTALL_DIR\"" EXIT

# Create temporary toolbox and run part 2 in it
echo "Creating temporary toolbox..."
if toolbox create -y solidcore-tmp &>/dev/null; then
    if ! toolbox run -c solidcore-tmp bash "$INSTALL_DIR/mscorefonts-part2.sh"; then
        echo "Error: Failed to run script in toolbox"
        exit 1
    fi
else
    echo "Error: Failed to create toolbox"
    exit 1
fi

# Makes directory
mkdir -pv ~/.config/fontconfig

# Copies config(s)
cp -v $HOME/Documents/linux_docs/configs/packages/fonts.conf $HOME/.config/fontconfig/

# Prints a conclusive message to end the script
echo "Microsoft fonts is now installed."
