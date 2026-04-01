#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

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

basic_function1() {
    echo "Hello world!"
}

basic_function1

basic_function2() {
    local message="$1"
    echo "$message"
}

basic_function2 "Hello world!"
