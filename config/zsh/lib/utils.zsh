#!/usr/bin/env zsh

# Common Utilities Module
# Shared functions used across multiple modules

# Check if a command exists
check_command() {
    command -v "$1" >/dev/null 2>&1
}

# Check if multiple commands exist
# Returns 0 if all exist, 1 if any are missing
require_commands() {
    local missing=()
    for cmd in "$@"; do
        check_command "$cmd" || missing+=("$cmd")
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Missing required commands: ${missing[*]}" >&2
        return 1
    fi
    return 0
}

# Check if commands exist and report missing ones
# Similar to require_commands but doesn't fail
check_optional_commands() {
    local missing=()
    for cmd in "$@"; do
        check_command "$cmd" || missing+=("$cmd")
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Optional commands not found: ${missing[*]}" >&2
    fi
    return 0
}

# Safe eval for environment variable expansion
# Only expands $HOME, $PWD, and $USER - nothing else
safe_expand_env() {
    local input="$1"
    # Replace only specific safe variables
    input="${input//\$HOME/$HOME}"
    input="${input//\$PWD/$PWD}"
    input="${input//\$USER/$USER}"
    input="${input//\${HOME}/$HOME}"
    input="${input//\${PWD}/$PWD}"
    input="${input//\${USER}/$USER}"
    echo "$input"
}

# Check if running on macOS
is_macos() {
    [[ "$(uname -s)" == "Darwin" ]]
}

# Check if running on Linux
is_linux() {
    [[ "$(uname -s)" == "Linux" ]]
}

# Get OS name
get_os_name() {
    uname -s
}

# Print colored messages
print_success() {
    echo "\033[0;32m✓ $*\033[0m"
}

print_error() {
    echo "\033[0;31m✗ $*\033[0m" >&2
}

print_warning() {
    echo "\033[1;33m⚠ $*\033[0m" >&2
}

print_info() {
    echo "\033[0;34mℹ $*\033[0m"
}

# Check if a file exists and is readable
file_readable() {
    [[ -f "$1" && -r "$1" ]]
}

# Check if a directory exists
dir_exists() {
    [[ -d "$1" ]]
}

# Create directory if it doesn't exist
ensure_dir() {
    [[ -d "$1" ]] || mkdir -p "$1"
}

# Source a file if it exists
safe_source() {
    [[ -f "$1" ]] && source "$1"
}

# Get user confirmation (y/n)
confirm() {
    local prompt="${1:-Continue?}"
    read -q "REPLY?$prompt (y/N): "
    echo
    [[ "$REPLY" == "y" || "$REPLY" == "Y" ]]
}
