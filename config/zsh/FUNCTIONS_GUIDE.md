# Shell Functions Reference Guide

Quick reference for all custom shell functions available in your dotfiles.

## 📦 Dotfiles Management

### `dot-status`
Shows system health dashboard for your dotfiles configuration. Displays current sync status and any configuration issues.

### `dot-audit`
Performs full XDG Base Directory compliance audit. Identifies any non-compliant configurations.

### `dot-sync`
Pulls latest changes from the dotfiles repository and syncs them to your live system.

### `dot-diff`
Shows differences between your live configuration and the repository version. Useful before syncing.

### `dot-update`
Applies repository updates to your live system. Add `--dry-run` to preview changes.

### `dot-health`
Complete health check covering all aspects: file integrity, permissions, XDG compliance, and sync status.

---

## 📁 Directory Navigation

### `mkcd <directory>`
Creates a directory and immediately changes into it. Saves typing `mkdir -p foo && cd foo`.

**Example:**
```bash
mkcd ~/projects/new-homelab-project
```

### `up [n]`
Go up N directories at once. Default is 1 level up.

**Example:**
```bash
up 3  # equivalent to cd ../../..
```

### `cdf <pattern>`
Find and cd to first directory matching the pattern. Uses `fd` if available, falls back to `find`.

**Example:**
```bash
cdf kubernetes  # finds and cd to first dir matching *kubernetes*
```

### `dsize [directory]`
Shows directory size excluding common large folders (node_modules, .git, target, dist). Much faster for development directories.

**Example:**
```bash
dsize ~/projects/web-app  # size without node_modules
```

---

## 📋 Project Management

### `proj [name]`
Switch to a project in your `$DEVELOPMENT_DIR`. Without arguments, lists available projects. Automatically loads `.env`/`.envrc` and shows git status.

**Example:**
```bash
proj homelab-automation  # cd to project and load environment
proj                      # list all projects
```

### `newproj <language> <name>`
Creates a new project with standard structure for the specified language. Supports: python, javascript, rust, go, misc.

**Example:**
```bash
newproj rust k3s-monitor  # creates rust project with cargo init
newproj python ansible-playbooks
```

**More info:** Project structures follow community best practices for each language.

---

## 🔧 Git Functions

### `gwt <branch>`
Creates a git worktree in parallel directory for the specified branch. Perfect for working on multiple branches simultaneously without stashing.

**Example:**
```bash
gwt feature-auth  # creates ../myproject-feature-auth/ worktree
```

**Learn more:** [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)

### `gct [message]`
Quick commit with timestamp. Stages all changes and commits with provided message or auto-generated timestamp.

**Example:**
```bash
gct "Fix K3s config"      # commits with your message
gct                        # commits with "Update: 2026-02-10 14:30"
```

### `gstatus`
Shows git status for all repositories in the current directory. Great for managing multiple projects.

**Example:**
```bash
cd ~/projects && gstatus  # status of all project repos
```

### `glogf`
Beautiful formatted git log with graph, colors, and compact display.

**Example:**
```bash
glogf  # shows formatted git history
```

---

## 🐳 Docker Functions

### `dcu [service]`
Docker compose up in detached mode. Optionally specify specific service(s).

**Example:**
```bash
dcu              # starts all services
dcu postgres     # starts only postgres service
```

### `dcd [service]`
Docker compose down. Optionally specify specific service(s).

**Example:**
```bash
dcd              # stops all services
dcd redis cache  # stops redis and cache services
```

### `dcl [service]`
Docker compose logs with follow. Optionally specify specific service(s).

**Example:**
```bash
dcl              # follows logs for all services
dcl web api      # follows logs for web and api services
```

### `dcleanup`
Nuclear option: prunes all stopped containers, unused images, networks, and volumes. Reclaims disk space.

**Example:**
```bash
dcleanup  # frees up Docker disk space
```

### `dsh <container>`
Opens an interactive shell into a Docker container. Tries bash first, falls back to sh.

**Example:**
```bash
dsh postgres  # opens shell in postgres container
```

---

## ☸️ Kubernetes Functions

### `kctx [name]`
Switch kubectl context. Without arguments, lists all available contexts.

**Example:**
```bash
kctx production  # switch to production cluster
kctx             # list all contexts
```

### `kns [name]`
Switch current kubectl namespace. Without arguments, shows current namespace.

**Example:**
```bash
kns monitoring   # switch to monitoring namespace
kns              # show current namespace
```

---

## 📄 File Operations

### `extract <file>`
Universal archive extractor. Supports: tar.gz, tar.bz2, tar.xz, zip, rar, 7z, and more.

**Example:**
```bash
extract backup.tar.gz
extract archive.zip
```

### `backup <file_or_directory>`
Creates timestamped backup copy in the same location.

**Example:**
```bash
backup config.yaml  # creates config.backup.20260210_143000.yaml
```

### `largest [n]`
Shows the N largest files/directories in current location. Default is 10.

**Example:**
```bash
largest 20  # shows 20 largest items
```

### `tailf <file> [lines]`
Tail last N lines and follow (live updates). Default is 50 lines.

**Example:**
```bash
tailf /var/log/syslog 100  # shows last 100 lines and follows
tailf app.log              # shows last 50 lines and follows
```

---

## 💻 System Information

### `sysinfo`
Comprehensive system summary including hostname, OS, uptime, disk usage, memory, and load average.

**Example:**
```bash
sysinfo  # displays complete system overview
```

### `port <port_number>`
Check what's using a specific port. Works with lsof, ss, or netstat (tries in that order).

**Example:**
```bash
port 8080  # shows process using port 8080
```

### `killport <port_number>`
Kill process(es) listening on a specific port. Useful when "address already in use" errors occur.

**Example:**
```bash
killport 3000  # kills process on port 3000
```

**Warning:** This uses `kill -9` (force kill). Use with caution in production.

---

## 🌐 Network Functions

### `serve [port]`
Starts HTTP server on localhost. Default port is 8000.

**Example:**
```bash
serve       # serves current directory on http://localhost:8000
serve 9000  # serves on port 9000
```

### `serve-lan [port]`
Starts HTTP server accessible from other devices on your local network (homelab devices, phones, etc.). Auto-detects your local IP.

**Example:**
```bash
serve-lan      # accessible from other devices on your LAN
serve-lan 8080 # serves on port 8080 across LAN
```

**Use case:** Perfect for testing web apps on mobile devices or accessing files from other homelab machines.

### `weather [city]`
Shows weather forecast using wttr.in. Without city argument, uses your current location.

**Example:**
```bash
weather          # weather for your location
weather Toronto  # weather for Toronto
weather "New York"  # use quotes for multi-word cities
```

---

## 🛠️ Utilities

### `genpass [length]`
Generates a random secure password. Default length is 16 characters.

**Example:**
```bash
genpass     # generates 16-char password
genpass 32  # generates 32-char password
```

### `timer <duration>`
Countdown timer with notification when finished. Duration format: 5m, 30s, 1h, etc.

**Example:**
```bash
timer 5m   # 5 minute timer
timer 30s  # 30 second timer
```

### `tabs2spaces <file>`
Converts tabs to 4 spaces in a file. Useful for consistent formatting.

**Example:**
```bash
tabs2spaces script.sh
```

### `loc [directory]`
Counts lines of code (excluding empty lines and comments) in Python, JavaScript, Rust, and Go files.

**Example:**
```bash
loc ~/projects/my-app  # count LOC in project
```

### `qr <text>`
Generates QR code for text. Useful for quickly sharing URLs or text with mobile devices.

**Example:**
```bash
qr "https://homelab.local"  # generates QR code for URL
```

---

## 📚 Additional Resources

- **Docker Compose:** [Official Documentation](https://docs.docker.com/compose/)
- **Kubernetes kubectl:** [Kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- **Git Worktrees:** [Git Worktree Tutorial](https://git-scm.com/docs/git-worktree)
- **XDG Base Directory:** [Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)

---

## 💡 Quick Tips

1. **Function discovery:** Type `funcs` to see a quick reference list of all functions
2. **Tab completion:** Most functions support tab completion for arguments
3. **Error safety:** Functions include input validation and helpful error messages
4. **Aliases vs Functions:** Use aliases for simple shortcuts, functions for anything needing parameters or logic
5. **Custom additions:** Add your own functions to `~/.config/dotfiles/zsh/functions.zsh`

---

*Generated: 2026-02-10 | See also: `~/.config/dotfiles/zsh/functions.zsh` for source code*
