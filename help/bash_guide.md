# Bash Guide
## Shebang
- `#!/usr/bin/env bash`

## Codes
- `0`       - success
- `1`       - failure
- `>=2`     - conditional failure
- `exit`    - exit the shell with a status code
- `return`  - return a status code from a function

## Conditionals
- `!`  - NOT
- `&&` - AND
- `||` - OR

## Guard Clauses
- `|| :`        - always succeed
- `|| return 1` - return from function on failure
- `|| exit 1`   - exit script on failure

## Variables
- `var="string"`    - assign a string variable
- `var=num`         - assign a numeric value
- `$var`            - expand variable
- `"${var}"`        - expand variable safely (prevents word splitting)
- `local var`       - declare a variable local to a function
- `export var`      - make a variable available to child processes
- `unset var`       - remove variable
- `readonly var`    - make var immutable

### Arrays
- `array=(a b c)`   - create array
- `array[0]=num`    - set element
- `"${array[@]}"`   - expand all elements
- `"${#array[@]}"`  - array length

### Special Variables
- `$?` - last command's exit status
- `$#` - number of script arguments
- `$@` - all arguments (preserves quoting)
- `$*` - all arguments (word-splitting)
- `$0` - script name
- `$1` - first argument
- `$2` - second argument
- `$3` - third argument (and so on)

### Parameter Expansion
- `${var:-default}` - use default if unset or empty
- `${var:=default}` - assign default if unset or empty
- `${var:?message}` - error if unset or empty
- `${var:+alt}`     - use alt if var is set

## Integer Arithmetic
### POSIX [ ]
- `-eq` - equal
- `-ne` - not equal
- `-gt` - greater than
- `-lt` - less than
- `-ge` - greater than or equal to
- `-le` - less than or equal to

```bash
if [ "$var" -eq 1 ]; then
    # action
fi
```

- Requires quoting `"$var"` to avoid word splitting and globbing

### Bash (( ))
- `==`  - equal
- `!=`  - not equal
- `>`   - greater than
- `<`   - less than
- `>=`  - greater than or equal to
- `<=`  - less than or equal to

```bash
if (( var == 1 )); then
    # action
fi
```

- Empty or unset variables evaluate as `0`, making arithmetic safer

## If Then Statements

```bash
# Path exists
if [ -e "$path" ]; then
    # action
fi

# Directory exists
if [ -d "$dir" ]; then
    # action
fi

# File exists
if [ -f "$file" ]; then
    # action
fi

# String is not empty
if [ -n "$var" ]; then
    # action
fi

# String is empty
if [ -z "$var" ]; then
    # action
fi

if function1; then
    # action1
elif function1; then
    # action2
else
    # action3
fi
```

## Case Statements

```bash
case "$var" in
    apple)  echo "apple" ;;
    banana) echo "banana" ;;
    *)      echo "idk" ;;
esac
```
## Loops
- `break` - break loop
- `continue` - skip to next loop run

```bash
while true; do
    # loop actions
done

for thing in "${things[@]}"; do
    # loop actions
done
```

## Common Commands
### Shell flow control
- `read` - read from stdin
    - `-e` - enable Readline editing (arrow keys, history, tab completion)
    - `-p` - prompt
    - `-r` - raw input
    
### Shell behavior and environment
- `set` - set/unset shell options
    - `-e` - exit on error
    - `-o` - option
    - `-u` - unset variable error
    - `pipefail` - fail on pipeline error
- `shopt` - shell behavior options
    - `-s` - set
    - `-u` - unset
    
### Text and pattern processing
- `echo` - print text to stdout
- `grep` - find patterns in files
    - `-E` - extended regular expressions
    - `-F` - treat pattern as literal text
    - `-i` - case-insensitive
    - `-v` - inverse match
    - `-q` - quiet
- `sed` - filter and transform text
    - `-i` - in-place replace
    
### Filesystem operations
- `cat` - print and concatenate files
- `cp` - copy files
    - `-r` - recursive
    - `-u` - update older files
    - `-v` - verbose
- `mv` - move or rename files/directories
    - `-v` - verbose
- `mkdir` - make directory
    - `-p` - create parents
    - `-v` - verbose
- `chmod` - modify permissions
    - `+` - add permissions
    - `-` - remove permissions
    - `g` - group
    - `o` - other
    - `r` - read
    - `u` - user
    - `w` - write
    - `x` - execute
    
### Networking and data transfer
- `curl` - transfer data over HTTP, HTTPS, and other protocols
    - `-f`    - fail on HTTP 4xx/5xx
    - `-s`    - hide all output, including errors
    - `-S`    - show errors if they occur (but stay silent otherwise)
    - `-L`    - follow redirects
- `rsync` - transfer files
    - `-a`            - archive
    - `-h`            - human-readable
    - `-u`            - update older files
    - `--delete`      - remove files not in source
    - `--progress`    - show progress
    
### System information and management
- `getent` - query system databases
- `systemctl` - manage systemd units
    - `disable` - disable service
    - `enable`  - enable service
    - `start`   - start service
    - `stop`    - stop service
    - `status`  - show service status
    - `--now`   - apply action immediately
- `usermod` - modify user accounts
    - `-a` - append to supplementary groups (use with -G)
    - `-G` - set supplementary groups (replaces list)
