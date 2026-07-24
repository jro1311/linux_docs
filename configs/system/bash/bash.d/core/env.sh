# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

determine_color_backend() {
  [ -n "${color_backend:-}" ] && return 0

  if command -v tput >/dev/null 2>&1; then
      color_backend="tput"
      red=$(tput setaf 1)
      green=$(tput setaf 2)
      yellow=$(tput setaf 3)
      blue=$(tput setaf 4)
      reset=$(tput sgr0)
  else
      color_backend="fallback"
      red=$'\033[31m'
      green=$'\033[32m'
      yellow=$'\033[33m'
      blue=$'\033[34m'
      reset=$'\033[0m'
  fi
}

determine_color_backend

# Ensures user-level bin directories take precedence in PATH
case ":$PATH:" in
  *":$HOME/.local/bin:$HOME/bin:"*) ;;
  *) PATH="$HOME/.local/bin:$HOME/bin:$PATH" ;;
esac

export LD_ROOT="$HOME/Documents/linux_docs"
export LD_CFG="$LD_ROOT/configs"
export LD_DOC="$LD_ROOT/documentation"
export LD_HELP="$LD_ROOT/help"
export LD_SCR="$LD_ROOT/scripts"
export LD_SS="$LD_ROOT/screenshots"
export LD_BASH="$LD_CFG/system/bash"
export LD_BASHD="$LD_BASH/bash.d"
export LBK1="/run/media/linux_backup1"
export LBK2="/run/media/linux_backup2"
export PATH="$PATH:/usr/sbin:/snap/bin"
export PATH

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    export PROTON_ENABLE_WAYLAND=1
else
    export PROTON_ENABLE_WAYLAND=0
fi
