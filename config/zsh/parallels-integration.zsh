#!/usr/bin/env zsh
# Parallels Desktop Integration (optional)
# Only loads if Parallels is installed

# Check if Parallels is installed
if ! command -v prlctl >/dev/null 2>&1; then
    return 0
fi

# === VM Management Functions ===

# List all VMs with their status
pvm() {
    echo "📦 Parallels Virtual Machines:"
    prlctl list -a
}

# Start a VM by name
pvm-start() {
    if [[ -z "$1" ]]; then
        echo "Usage: pvm-start <vm_name>"
        echo "Available VMs:"
        prlctl list -a -o name,status | grep stopped | cut -d' ' -f1
        return 1
    fi

    echo "🚀 Starting VM: $1"
    prlctl start "$1"
}

# Stop a VM by name
pvm-stop() {
    if [[ -z "$1" ]]; then
        echo "Usage: pvm-stop <vm_name>"
        echo "Running VMs:"
        prlctl list -o name,status | grep running | cut -d' ' -f1
        return 1
    fi

    echo "🛑 Stopping VM: $1"
    prlctl stop "$1"
}

# Connect to VM console
pvm-console() {
    if [[ -z "$1" ]]; then
        echo "Usage: pvm-console <vm_name>"
        prlctl list -a -o name
        return 1
    fi

    # Start VM if not running
    local status=$(prlctl status "$1" 2>/dev/null | grep -o "running\|stopped")
    if [[ "$status" == "stopped" ]]; then
        echo "VM is stopped, starting..."
        prlctl start "$1"
        sleep 3
    fi

    prlctl console "$1"
}

# Execute command in VM
pvm-exec() {
    if [[ -z "$1" ]] || [[ -z "$2" ]]; then
        echo "Usage: pvm-exec <vm_name> <command>"
        return 1
    fi

    local vm_name="$1"
    shift
    prlctl exec "$vm_name" "$@"
}

# SSH into VM (requires VM to have SSH enabled)
pvm-ssh() {
    if [[ -z "$1" ]]; then
        echo "Usage: pvm-ssh <vm_name> [user]"
        return 1
    fi

    local vm_name="$1"
    local user="${2:-$(whoami)}"

    # Get VM IP address
    local vm_ip=$(prlctl list -f -o ip "$vm_name" | tail -n1 | tr -d ' ')

    if [[ -z "$vm_ip" ]] || [[ "$vm_ip" == "-" ]]; then
        echo "Could not get IP for VM: $vm_name"
        echo "Make sure VM is running and has network configured"
        return 1
    fi

    echo "Connecting to $vm_name ($vm_ip) as $user..."
    ssh "$user@$vm_ip"
}

# Create snapshot
pvm-snapshot() {
    if [[ -z "$1" ]]; then
        echo "Usage: pvm-snapshot <vm_name> [snapshot_name]"
        return 1
    fi

    local vm_name="$1"
    local snapshot_name="${2:-snapshot-$(date +%Y%m%d-%H%M%S)}"

    echo "📸 Creating snapshot '$snapshot_name' for $vm_name..."
    prlctl snapshot "$vm_name" --name "$snapshot_name"
}

# List snapshots
pvm-snapshots() {
    if [[ -z "$1" ]]; then
        echo "Usage: pvm-snapshots <vm_name>"
        return 1
    fi

    echo "📸 Snapshots for $1:"
    prlctl snapshot-list "$1"
}

# Clone a VM
pvm-clone() {
    if [[ -z "$1" ]] || [[ -z "$2" ]]; then
        echo "Usage: pvm-clone <source_vm> <new_vm_name>"
        return 1
    fi

    echo "📋 Cloning $1 to $2..."
    prlctl clone "$1" --name "$2"
}

# === Work-Specific VM Shortcuts ===
# Customize these for your environment

# Launch Windows VM for Excel/Office work
work-windows() {
    pvm-console "Windows 11"  # Change to your Windows VM name
}

# Launch Ubuntu development VM
work-ubuntu() {
    pvm-console "Ubuntu Dev"  # Change to your Ubuntu VM name
}

# Launch testing environment
work-test() {
    pvm-console "Test Environment"  # Change to your test VM name
}

# === Interactive VM Selector ===

pvm-select() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "fzf is required for interactive selection"
        return 1
    fi

    local vm=$(prlctl list -a -o name | tail -n +2 | fzf --prompt="Select VM: " --height=40%)

    if [[ -n "$vm" ]]; then
        echo "Selected: $vm"
        echo "Options:"
        echo "  1) Start/Console"
        echo "  2) Stop"
        echo "  3) SSH"
        echo "  4) Info"
        read -r "choice?Choose action (1-4): "

        case "$choice" in
            1) pvm-console "$vm" ;;
            2) pvm-stop "$vm" ;;
            3) pvm-ssh "$vm" ;;
            4) prlctl list -i "$vm" ;;
            *) echo "Invalid choice" ;;
        esac
    fi
}

# === Aliases for Common Operations ===

alias pvms='pvm'                    # List VMs
alias pvm-ls='pvm'                  # List VMs
alias pvm-on='pvm-start'            # Start VM
alias pvm-off='pvm-stop'            # Stop VM
alias pvm-snap='pvm-snapshot'       # Create snapshot
alias pvm-pick='pvm-select'         # Interactive selector

# === Helpful Tips ===

pvm-help() {
    cat << 'EOF'
Parallels VM Management Functions:

Core Commands:
  pvm                      - List all VMs with status
  pvm-start <name>         - Start a VM
  pvm-stop <name>          - Stop a VM
  pvm-console <name>       - Connect to VM console
  pvm-ssh <name> [user]    - SSH into VM
  pvm-exec <name> <cmd>    - Execute command in VM

Snapshots:
  pvm-snapshot <name>      - Create snapshot
  pvm-snapshots <name>     - List snapshots

Management:
  pvm-clone <src> <dest>   - Clone a VM
  pvm-select               - Interactive VM selector (requires fzf)

Work Shortcuts (customize these):
  work-windows             - Launch Windows VM
  work-ubuntu              - Launch Ubuntu Dev VM
  work-test                - Launch Test Environment

Examples:
  pvm-start "Windows 11"
  pvm-ssh "Ubuntu Dev" myuser
  pvm-exec "Ubuntu Dev" "apt update && apt upgrade -y"
  pvm-snapshot "Windows 11" "before-update"

EOF
}
