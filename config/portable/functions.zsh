#!/usr/bin/env zsh
# Portable Dotfiles - Essential Functions Only
# Minimal set for SSH sessions on remote servers

# Make directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Go up N directories
up() {
    local levels=${1:-1}
    local path=""
    for ((i=0; i<levels; i++)); do
        path="../$path"
    done
    cd "$path" || return 1
}

# Extract archives (any type)
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"    ;;
            *.tar.gz)    tar xzf "$1"    ;;
            *.bz2)       bunzip2 "$1"    ;;
            *.rar)       unrar x "$1"    ;;
            *.gz)        gunzip "$1"     ;;
            *.tar)       tar xf "$1"     ;;
            *.tbz2)      tar xjf "$1"    ;;
            *.tgz)       tar xzf "$1"    ;;
            *.zip)       unzip "$1"      ;;
            *.Z)         uncompress "$1" ;;
            *.7z)        7z x "$1"       ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Find process by name
psg() {
    ps aux | grep -v grep | grep -i -e VSZ -e "$1"
}

# Show listening ports
listening() {
    if command -v lsof >/dev/null 2>&1; then
        lsof -i -P -n | grep LISTEN
    elif command -v netstat >/dev/null 2>&1; then
        netstat -tulanp 2>/dev/null | grep LISTEN
    else
        echo "Neither lsof nor netstat available"
    fi
}

# Quick HTTP server
serve() {
    local port=${1:-8000}
    echo "Serving on http://localhost:$port"
    python3 -m http.server "$port" 2>/dev/null || python -m SimpleHTTPServer "$port"
}

# Find and cd to directory
cdf() {
    local dir
    dir=$(find ${1:-.} -type d 2>/dev/null | fzf +m) && cd "$dir"
}

# Quick backup
bak() {
    cp "$1" "$1.bak.$(date +%Y%m%d_%H%M%S)"
}
