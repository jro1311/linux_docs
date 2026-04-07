# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

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
if ! [[ "$PATH" =~ $HOME/.local/bin:$HOME/bin: ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

export LD_ROOT="$HOME/Documents/linux_docs"
export LD_CFG="$LD_ROOT/configs"
export LD_DOC="$LD_ROOT/documentation"
export LD_HELP="$LD_ROOT/help"
export LD_SCR="$LD_ROOT/scripts"
export LD_SS="$LD_ROOT/screenshots"
export LBK1="/run/media/linux_backup1"
export LBK2="/run/media/linux_backup2"
export PATH="$PATH:/usr/sbin:/snap/bin"
export PATH
