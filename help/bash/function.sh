#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

basic_function1() {
    echo "Hello world!"
}

basic_function1

basic_function2() {
    local message="$1"
    echo "$message"
}

basic_function2 "Hello world!"
