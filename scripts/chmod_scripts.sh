#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

. "$HOME/Documents/linux_docs/configs/system/bash/bashrc.d/helpers/source.sh"
source_all "$HOME/Documents/linux_docs/configs/system/bash/bashrc.d"

find "$HOME/Documents/linux_docs/scripts" -type f \
    -name "*.sh" \
    -exec chmod +x {} +

green_message "Success:" "All scripts are now executable."
