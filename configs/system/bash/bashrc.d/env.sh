# shellcheck shell=bash

# Define terminal text colors using tput
if command -v tput &>/dev/null; then
    red=$(tput setaf 1)
    green=$(tput setaf 2)
    yellow=$(tput setaf 3)
    blue=$(tput setaf 4)
    reset=$(tput sgr0)
else
    # Fallback for systems without tput
    red=$'\033[31m'
    green=$'\033[32m'
    yellow=$'\033[33m'
    blue=$'\033[34m'
    reset=$'\033[0m'
fi

# Get the current user's primary group
group=$(id -gn)

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

export LINUX_DOCS="$HOME/Documents/linux_docs"
export LINUX_DOCS_CONFIGS="$HOME/Documents/linux_docs/configs"
export LINUX_DOCS_DOCUMENTATION="$HOME/Documents/linux_docs/documentation"
export LINUX_DOCS_HELP="$HOME/Documents/linux_docs/help"
export LINUX_DOCS_SCRIPTS="$HOME/Documents/linux_docs/scripts"
export LINUX_DOCS_SCREENSHOTS="$HOME/Documents/linux_docs/screenshots"
export LINUX_BACKUP1="/run/media/linux_backup1"
export LINUX_BACKUP2="/run/media/linux_backup2"
export PATH="$PATH:/usr/sbin:/snap/bin"
export PATH
