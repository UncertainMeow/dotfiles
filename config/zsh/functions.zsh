#!/usr/bin/env zsh

# Custom Functions - The "Lego Block" Approach

# Kill any aliases that collide with function names
# This prevents "defining function based on alias" errors
unalias -m 'weather|funcs|mkcd|proj|serve' 2>/dev/null

# === Directory Operations ===

# Make directory and cd into it
mkcd() {
    if [[ -z "$1" ]]; then
        echo "Usage: mkcd <directory>"
        return 1
    fi
    mkdir -p "$1" && cd "$1"
}

# Go up N directories
up() {
    local levels=${1:-1}
    local path=""
    for ((i=1; i<=levels; i++)); do
        path="../$path"
    done
    cd "$path"
}

# Find and cd to directory
cdf() {
    if [[ -z "$1" ]]; then
        echo "Usage: cdf <directory_pattern>"
        return 1
    fi
    
    local dir
    if command -v fd > /dev/null 2>&1; then
        dir=$(fd -t d "$1" | head -1)
    else
        dir=$(find . -type d -name "*$1*" | head -1)
    fi
    
    if [[ -n "$dir" ]]; then
        cd "$dir"
        echo "Changed to: $(pwd)"
    else
        echo "Directory matching '$1' not found"
        return 1
    fi
}

# === Project Management ===

# Quick project switcher
proj() {
    if [[ -z "$1" ]]; then
        echo "Available projects:"
        ls -1 "$DEVELOPMENT_DIR" 2>/dev/null | head -10
        return 0
    fi
    
    local project_path="$DEVELOPMENT_DIR/$1"
    if [[ -d "$project_path" ]]; then
        cd "$project_path"
        echo "Switched to project: $1"
        
        # Source project-specific environment if it exists
        [[ -f ".env" ]] && echo "Loading .env..." && source ".env"
        [[ -f ".envrc" ]] && echo "Loading .envrc..." && source ".envrc"
        
        # Show git status if it's a git repo
        if git rev-parse --git-dir > /dev/null 2>&1; then
            echo "\nGit status:"
            git status --short
        fi
        
        # Show recent commits
        if git rev-parse --git-dir > /dev/null 2>&1; then
            echo "\nRecent commits:"
            git log --oneline -5
        fi
    else
        echo "Project '$1' not found in $DEVELOPMENT_DIR"
        return 1
    fi
}

# Create new project with standard structure
newproj() {
    if [[ -z "$1" ]] || [[ -z "$2" ]]; then
        echo "Usage: newproj <language> <project_name>"
        echo "Languages: python, javascript, rust, go, misc"
        return 1
    fi
    
    local lang="$1"
    local name="$2"
    local project_dir="$DEVELOPMENT_DIR/$lang/$name"
    
    if [[ -d "$project_dir" ]]; then
        echo "Project already exists: $project_dir"
        return 1
    fi
    
    mkdir -p "$project_dir"
    cd "$project_dir"
    
    # Initialize git repo
    git init
    
    # Create language-specific structure
    case "$lang" in
        python)
            touch requirements.txt README.md .gitignore
            mkdir -p src tests
            echo "# $name\n\n" > README.md
            curl -s https://raw.githubusercontent.com/github/gitignore/main/Python.gitignore > .gitignore
            ;;
        javascript)
            npm init -y
            touch README.md .gitignore
            mkdir -p src
            echo "node_modules/\n*.log\n.env" > .gitignore
            ;;
        rust)
            cargo init --name "$name"
            ;;
        go)
            go mod init "$name"
            touch main.go README.md
            mkdir -p cmd internal pkg
            ;;
        *)
            touch README.md .gitignore
            ;;
    esac
    
    echo "Created $lang project: $name"
    echo "Location: $project_dir"
}

# === Git Functions ===

# Git worktree management (great for parallel work)
gwt() {
    if [[ -z "$1" ]]; then
        echo "Usage: gwt <branch_name>"
        echo "Creates a worktree at ../$(basename $(pwd))-<branch>"
        return 1
    fi

    local branch="$1"
    local worktree_dir="../$(basename $(pwd))-$branch"

    git worktree add "$worktree_dir" "$branch"
    echo "✓ Worktree created: $worktree_dir"
    echo "  cd to it: cd $worktree_dir"
}

# Git commit with timestamp
gct() {
    local message="${1:-Update: $(date '+%Y-%m-%d %H:%M')}"
    git add . && git commit -m "$message"
}

# Quick git status for all repos in current directory
gstatus() {
    for dir in */; do
        if [[ -d "$dir/.git" ]]; then
            echo "=== $dir ==="
            (cd "$dir" && git status --short)
            echo
        fi
    done
}

# Git log with custom format
glogf() {
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
}

# === File Operations ===

# Extract any archive
extract() {
    if [[ -z "$1" ]]; then
        echo "Usage: extract <file>"
        return 1
    fi
    
    if [[ ! -f "$1" ]]; then
        echo "File not found: $1"
        return 1
    fi
    
    case "$1" in
        *.tar.bz2)   tar xvjf "$1"   ;;
        *.tar.gz)    tar xvzf "$1"   ;;
        *.tar.xz)    tar xvJf "$1"   ;;
        *.bz2)       bunzip2 "$1"    ;;
        *.rar)       unrar x "$1"    ;;
        *.gz)        gunzip "$1"     ;;
        *.tar)       tar xvf "$1"    ;;
        *.tbz2)      tar xvjf "$1"   ;;
        *.tgz)       tar xvzf "$1"   ;;
        *.zip)       unzip "$1"      ;;
        *.Z)         uncompress "$1" ;;
        *.7z)        7z x "$1"       ;;
        *.xz)        unxz "$1"       ;;
        *.exe)       cabextract "$1" ;;
        *)           echo "Unknown archive format: $1" ;;
    esac
}

# Quick backup of file or directory
backup() {
    if [[ -z "$1" ]]; then
        echo "Usage: backup <file_or_directory>"
        return 1
    fi
    
    local item="$1"
    local backup_name="${item%.*/}.backup.$(date +%Y%m%d_%H%M%S)"
    
    if [[ -f "$item" ]]; then
        cp "$item" "$backup_name"
    elif [[ -d "$item" ]]; then
        cp -r "$item" "$backup_name"
    else
        echo "File or directory not found: $item"
        return 1
    fi
    
    echo "Backup created: $backup_name"
}

# === System Information ===

# System summary
sysinfo() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "OS: $(uname -sr)"
    echo "Uptime: $(uptime | cut -d',' -f1 | cut -d' ' -f4-)"
    echo "Shell: $SHELL"
    echo "User: $USER"
    echo "Date: $(date)"
    echo
    echo "=== Disk Usage ==="
    df -h | head -5
    echo
    echo "=== Memory Usage ==="
    free -h 2>/dev/null || vm_stat | head -5
    echo
    echo "=== Load Average ==="
    uptime
}

# Show largest files in directory
largest() {
    local count=${1:-10}
    du -ah . | sort -rh | head -n "$count"
}

# Directory size with exclusions (faster for development directories)
dsize() {
    local target="${1:-.}"
    echo "Calculating size of $target (excluding node_modules, .git)..."
    du -sh "$target" --exclude=node_modules --exclude=.git --exclude=target --exclude=dist 2>/dev/null || \
        du -sh "$target" 2>/dev/null
}

# === Network Functions ===

# Port checker with enhanced fallbacks
port() {
    if [[ -z "$1" ]]; then
        echo "Usage: port <port_number>"
        return 1
    fi

    local port="$1"
    if command -v lsof > /dev/null 2>&1; then
        lsof -i ":$port" 2>/dev/null || echo "Nothing listening on port $port"
    elif command -v ss > /dev/null 2>&1; then
        ss -tulpn 2>/dev/null | grep ":$port" || echo "Nothing listening on port $port"
    elif command -v netstat > /dev/null 2>&1; then
        netstat -tuln 2>/dev/null | grep ":$port" || echo "Nothing listening on port $port"
    else
        echo "No port checking tool available (tried: lsof, ss, netstat)"
        return 1
    fi
}

# Kill process by port (great for development)
killport() {
    if [[ -z "$1" ]]; then
        echo "Usage: killport <port_number>"
        return 1
    fi

    local port="$1"
    if command -v lsof > /dev/null 2>&1; then
        local pids=$(lsof -ti ":$port" 2>/dev/null)
        if [[ -n "$pids" ]]; then
            echo "Killing processes on port $port: $pids"
            echo "$pids" | xargs kill -9
            echo "✓ Processes killed"
        else
            echo "No process found on port $port"
        fi
    else
        echo "lsof not available"
        return 1
    fi
}

# Quick HTTP server
serve() {
    local port=${1:-8000}
    echo "Serving on http://localhost:$port"
    python3 -m http.server "$port"
}

# Serve on LAN (accessible from other homelab devices)
serve-lan() {
    local port=${1:-8000}
    local ip

    # Try to get local IP
    if command -v ipconfig > /dev/null 2>&1; then
        # macOS
        ip=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)
    elif command -v hostname > /dev/null 2>&1; then
        # Linux
        ip=$(hostname -I 2>/dev/null | cut -d' ' -f1)
    fi

    if [[ -n "$ip" ]]; then
        echo "🌐 Serving on http://$ip:$port"
        echo "   (Accessible from other devices on your network)"
        python3 -m http.server "$port" --bind "$ip"
    else
        echo "⚠️  Could not determine local IP, serving on all interfaces"
        python3 -m http.server "$port" --bind 0.0.0.0
    fi
}

# === Text Processing ===

# Convert tabs to spaces
tabs2spaces() {
    if [[ -z "$1" ]]; then
        echo "Usage: tabs2spaces <file>"
        return 1
    fi
    expand -t 4 "$1" > "${1}.spaces" && mv "${1}.spaces" "$1"
    echo "Converted tabs to spaces in $1"
}

# Count lines of code (excluding empty lines and comments)
loc() {
    local dir=${1:-.}
    find "$dir" -type f \( -name "*.py" -o -name "*.js" -o -name "*.rs" -o -name "*.go" \) \
        -exec grep -v -E '^\s*$|^\s*#|^\s*//' {} \; | wc -l
}

# === Docker Functions ===

# Docker compose shortcuts
dcu() {
    docker compose up -d "$@"
}

dcd() {
    docker compose down "$@"
}

dcl() {
    docker compose logs -f "$@"
}

# Docker cleanup
dcleanup() {
    echo "Cleaning up Docker..."
    docker system prune -af
    docker volume prune -f
    echo "Docker cleanup complete"
}

# Docker shell into container
dsh() {
    if [[ -z "$1" ]]; then
        echo "Usage: dsh <container_name_or_id>"
        return 1
    fi
    
    local container="$1"
    if docker exec -it "$container" /bin/bash 2>/dev/null; then
        return 0
    elif docker exec -it "$container" /bin/sh 2>/dev/null; then
        return 0
    else
        echo "Failed to get shell in container: $container"
        return 1
    fi
}

# === Kubernetes Functions ===

# Quick context switching
kctx() {
    if [[ -z "$1" ]]; then
        echo "Available contexts:"
        kubectl config get-contexts
        return 0
    fi
    kubectl config use-context "$1"
}

# Quick namespace switching
kns() {
    if [[ -z "$1" ]]; then
        echo "Current namespace:"
        kubectl config view --minify --output 'jsonpath={..namespace}'
        echo
        return 0
    fi
    kubectl config set-context --current --namespace="$1"
    echo "✓ Switched to namespace: $1"
}

# === Utility Functions ===

# Tail with follow and configurable lines
tailf() {
    if [[ -z "$1" ]]; then
        echo "Usage: tailf <file> [lines]"
        return 1
    fi
    local file="$1"
    local lines="${2:-50}"
    tail -n "$lines" -f "$file"
}

# Weather for specific city
weather() {
    local city=${1:-"$(curl -s ipinfo.io/city 2>/dev/null)"}
    curl -s "wttr.in/$city"
}

# Generate random password
genpass() {
    local length=${1:-16}
    openssl rand -base64 "$length" | head -c "$length"
    echo
}

# QR code for text
qr() {
    if [[ -z "$1" ]]; then
        echo "Usage: qr <text>"
        return 1
    fi
    curl -s "qr-server.com/api/v1/create-qr-code/?size=150x150&data=$1"
}

# Timer function
timer() {
    local duration="$1"
    if [[ -z "$duration" ]]; then
        echo "Usage: timer <duration> (e.g., 5m, 30s, 1h)"
        return 1
    fi
    
    echo "Timer started for $duration"
    sleep "$duration" && echo "⏰ Timer finished!"
}

# === Help Function ===

# === Dotfiles Management ===

# Find dotfiles management script
_find_dot_script() {
    local locations=(
        "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/dot-manage.sh"
        "$HOME/dotfiles/scripts/dot-manage.sh"
        "$HOME/.dotfiles/dot-manage.sh"
        "$HOME/dotfiles/dot-manage.sh"
    )

    for location in "${locations[@]}"; do
        if [[ -f "$location" ]]; then
            echo "$location"
            return 0
        fi
    done

    if command -v dot-manage.sh > /dev/null 2>&1; then
        echo "dot-manage.sh"
        return 0
    fi

    return 1
}

# Dotfiles status check
dot-status() {
    local dot_script
    if dot_script=$(_find_dot_script); then
        "$dot_script" status
    else
        echo "📦 Dotfiles management not found"
        echo "💡 Run 'install.sh' to set up your environment"
        echo "   or check if dot-manage.sh is in your PATH"
    fi
}

# Dotfiles system audit
dot-audit() {
    local dot_script
    if dot_script=$(_find_dot_script); then
        "$dot_script" audit
    else
        echo "📦 Dotfiles management not found"
        echo "💡 Run 'install.sh' to set up your environment"
    fi
}

# Sync with repository
dot-sync() {
    local dot_script
    if dot_script=$(_find_dot_script); then
        "$dot_script" sync
    else
        echo "📦 Dotfiles management not found"
        echo "💡 Run 'install.sh' to set up your environment"
    fi
}

# Update system
dot-update() {
    local dot_script
    local dry_run_flag=""
    [[ "$1" == "--dry-run" ]] && dry_run_flag="--dry-run"

    if dot_script=$(_find_dot_script); then
        "$dot_script" update $dry_run_flag
    else
        echo "📦 Dotfiles management not found"
        echo "💡 Run 'install.sh' to set up your environment"
    fi
}

# Show differences
dot-diff() {
    local dot_script
    if dot_script=$(_find_dot_script); then
        "$dot_script" diff
    else
        echo "📦 Dotfiles management not found"
        echo "💡 Run 'install.sh' to set up your environment"
    fi
}

# Complete health check
dot-health() {
    local dot_script
    if dot_script=$(_find_dot_script); then
        "$dot_script" health
    else
        echo "📦 Dotfiles management not found"
        echo "💡 Run 'install.sh' to set up your environment"
    fi
}

# Show available custom functions
funcs() {
    echo "Available custom functions:"
    echo
    echo "📦 Dotfiles Management:"
    echo "  dot-status   - System health dashboard"
    echo "  dot-audit    - Full XDG compliance audit"
    echo "  dot-sync     - Pull latest from repository"
    echo "  dot-diff     - Show differences from repo"
    echo "  dot-update   - Apply repository updates"
    echo "  dot-health   - Complete health check"
    echo
    echo "📁 Directory:"
    echo "  mkcd <dir>     - Make and cd to directory"
    echo "  up [n]         - Go up N directories"
    echo "  cdf <pattern>  - Find and cd to directory"
    echo "  dsize [dir]    - Directory size (excludes node_modules, .git)"
    echo
    echo "📋 Projects:"
    echo "  proj [name]    - Switch to project or list projects"
    echo "  newproj <lang> <name> - Create new project"
    echo
    echo "🔧 Git:"
    echo "  gwt <branch>   - Create git worktree for parallel work"
    echo "  gct [msg]      - Commit with timestamp"
    echo "  gstatus        - Status of all repos in current dir"
    echo "  glogf          - Formatted git log"
    echo
    echo "🐳 Docker:"
    echo "  dcu [service]  - Docker compose up -d"
    echo "  dcd [service]  - Docker compose down"
    echo "  dcl [service]  - Docker compose logs -f"
    echo "  dcleanup       - Clean up Docker (prune everything)"
    echo
    echo "☸️  Kubernetes:"
    echo "  kctx [name]    - Switch kubectl context"
    echo "  kns [name]     - Switch kubectl namespace"
    echo
    echo "📄 Files:"
    echo "  extract <file> - Extract any archive"
    echo "  backup <item>  - Backup file or directory"
    echo "  largest [n]    - Show largest files"
    echo "  tailf <file> [n] - Tail last N lines and follow"
    echo
    echo "💻 System:"
    echo "  sysinfo        - System information summary"
    echo "  port <num>     - Check what's using a port"
    echo "  killport <num> - Kill process by port number"
    echo
    echo "🌐 Network:"
    echo "  serve [port]     - HTTP server on localhost"
    echo "  serve-lan [port] - HTTP server accessible on LAN"
    echo "  weather [city]   - Weather forecast"
    echo
    echo "🛠️  Utils:"
    echo "  genpass [len]  - Generate random password"
    echo "  timer <time>   - Countdown timer"
}
