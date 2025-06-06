#!/usr/bin/env bash

# Disclaimer: I did not write this script. All credit goes to GloriousEggroll.
# Source: https://github.com/GloriousEggroll/proton-ge-custom?tab=readme-ov-file#native

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Makes temp working directory
echo "Creating temporary working directory..."
rm -rf /tmp/proton-ge-custom
mkdir /tmp/proton-ge-custom
cd /tmp/proton-ge-custom

# Downloads tarball
echo "Fetching tarball URL..."
tarball_url=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .tar.gz)
tarball_name=$(basename "$tarball_url")
echo "Downloading tarball: $tarball_name..."
curl -# -L "$tarball_url" -o "$tarball_name" --no-progress-meter

# Downloads checksum
echo "Fetching checksum URL..."
checksum_url=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .sha512sum)
checksum_name=$(basename "$checksum_url")
echo "Downloading checksum: $checksum_name..."
curl -# -L "$checksum_url" -o "$checksum_name" --no-progress-meter

# Checks tarball with checksum
echo "Verifying tarball $tarball_name with checksum $checksum_name..."
sha512sum -c "$checksum_name"
# If result is ok, continues

# Makes steam directory if it does not exist
echo "Creating Steam directory if it does not exist..."
mkdir -p "$HOME"/.steam/steam/compatibilitytools.d

# Extracts proton tarball to steam directory
echo "Extracting $tarball_name to Steam directory..."
tar -xf "$tarball_name" -C "$HOME"/.steam/steam/compatibilitytools.d/
echo "All done :)"

# Prints a conclusive message
echo "Proton GE is now installed. Restart Steam to enable it."
