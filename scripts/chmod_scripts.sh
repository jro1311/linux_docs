#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# shellcheck disable=SC2044
# Sources all .sh files in bashrc.d
for rc in $(find "$HOME/Documents/linux_docs/configs/system/bash/bashrc.d" -type f -name '*.sh' 2>/dev/null); do
    . "$rc"
done

# Makes all .sh files in scripts executable
find "$HOME/Documents/linux_docs/scripts" -type f \
    -name "*.sh" \
    -exec chmod +x {} +

green_message "Success:" "All scripts are now executable."
