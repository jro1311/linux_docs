#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

basic_function1() {
    echo "Hello!"
}

basic_function1

basic_function2() {
    local message="$1"
    echo "$message"
}

basic_function2 "Goodbye."

basic_function3() {
    basic_function1
    basic_function2 "Goodbye."
}
