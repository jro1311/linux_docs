#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Changes directory
cd "$HOME"/Documents

# Renames directory
mv -v ./linux_docs ./linux_docs_old

# Clones git repository
git clone https://github.com/jro1311/linux_docs.git

# Print a conclusive message to end the script
echo "Git clone complete."
