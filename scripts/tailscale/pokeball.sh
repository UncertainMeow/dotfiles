#!/usr/bin/env bash
# =============================================================================
# TAILSCALE PROVISIONER
# =============================================================================
# Automatically provision any server/container/VM onto your Tailnet
# Usage: ./provision.sh [OPTIONS] [hostname]

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
TAILSCALE_AUTHKEY="${TAILSCALE_AUTHKEY:-}"
HOSTNAME="${1:-}"
TAGS=""
ADVERTISE_ROUTES=""
ACCEPT_ROUTES=false
ENABLE_SSH=true
REGISTER_DNS=false
NETBOX_URL="${NETBOX_URL:-}"
NETBOX_TOKEN="${NETBOX_TOKEN:-}"

# Detect if running as root (no sudo needed)
if [[ $EUID -eq 0 ]]; then
    SUDO=""
else
    SUDO="sudo"
fi

# Show usage
usage() {
    cat << EOF
${BLUE}╔══════════════════════════════════════════════════════════╗${NC}
${BLUE}║        🔷 Tailscale Provisioner                        ║${NC}
${BLUE}║        "Hey you - you're on the tailnet now!"          ║${NC}
${BLUE}╚══════════════════════════════════════════════════════════╝${NC}

${YELLOW}Usage:${NC}
  $0 [OPTIONS] <hostname>

${YELLOW}Options:${NC}
  -k, --authkey KEY      Tailscale auth key (or set TAILSCALE_AUTHKEY env)
  -t, --tags TAGS        Tailscale tags (comma-separated: tag:server,tag:prod)
  -r, --routes ROUTES    Advertise routes (comma-separated: 10.0.0.0/24,192.168.1.0/24)
  -a, --accept-routes    Accept routes from other nodes
  --no-ssh               Disable Tailscale SSH
  --register-dns         Register in DNS/NetBox (requires NETBOX_URL/TOKEN)
  -h, --help             Show this help

${YELLOW}Examples:${NC}
  # Basic provisioning with name "jeremy"
  $0 jeremy

  # Production server with tags and route advertisement
  $0 -t tag:server,tag:prod -r 10.0.1.0/24 web-01

  # Full setup with DNS registration
  $0 --register-dns -k tskey-auth-xxx database-server

${YELLOW}Environment Variables:${NC}
  TAILSCALE_AUTHKEY  - Auth key for joining tailnet
  NETBOX_URL         - NetBox API URL (for DNS registration)
  NETBOX_TOKEN       - NetBox API token

EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -k|--authkey)
            TAILSCALE_AUTHKEY="$2"
            shift 2
            ;;
        -t|--tags)
            TAGS="$2"
            shift 2
            ;;
        -r|--routes)
            ADVERTISE_ROUTES="$2"
            shift 2
            ;;
        -a|--accept-routes)
            ACCEPT_ROUTES=true
            shift
            ;;
        --no-ssh)
            ENABLE_SSH=false
            shift
            ;;
        --register-dns)
            REGISTER_DNS=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        -*)
            echo -e "${RED}✗${NC} Unknown option: $1"
            usage
            ;;
        *)
            HOSTNAME="$1"
            shift
            ;;
    esac
done

# Validate hostname
if [[ -z "$HOSTNAME" ]]; then
    echo -e "${RED}✗${NC} Hostname required!"
    echo ""
    usage
fi

# Header
echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║        🔷 Provisioning $HOSTNAME to Tailnet            ║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Detect OS
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
    else
        OS=$(uname -s | tr '[:upper:]' '[:lower:]')
        OS_VERSION="unknown"
    fi

    echo -e "${GREEN}✓${NC} Detected OS: $OS $OS_VERSION"
}

# Install Tailscale
install_tailscale() {
    if command -v tailscale >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Tailscale already installed"
        return 0
    fi

    echo -e "${BLUE}ℹ${NC}  Installing Tailscale..."

    case "$OS" in
        ubuntu|debian)
            curl -fsSL https://tailscale.com/install.sh | sh
            ;;
        centos|rhel|fedora)
            curl -fsSL https://tailscale.com/install.sh | sh
            ;;
        arch)
            $SUDO pacman -Sy --noconfirm tailscale
            $SUDO systemctl enable --now tailscaled
            ;;
        *)
            echo -e "${RED}✗${NC} Unsupported OS: $OS"
            echo -e "${YELLOW}💡${NC} Install manually: https://tailscale.com/download"
            exit 1
            ;;
    esac

    echo -e "${GREEN}✓${NC} Tailscale installed"
}

# Authenticate with Tailscale
authenticate() {
    echo -e "${BLUE}ℹ${NC}  Authenticating with Tailnet..."

    # Build tailscale up command
    local cmd="$SUDO tailscale up"

    # Add authkey if provided
    if [[ -n "$TAILSCALE_AUTHKEY" ]]; then
        cmd+=" --authkey=\"$TAILSCALE_AUTHKEY\""
    fi

    # Add hostname
    cmd+=" --hostname=\"$HOSTNAME\""

    # Add tags
    if [[ -n "$TAGS" ]]; then
        cmd+=" --advertise-tags=\"$TAGS\""
    fi

    # Add route advertisement
    if [[ -n "$ADVERTISE_ROUTES" ]]; then
        cmd+=" --advertise-routes=\"$ADVERTISE_ROUTES\""
    fi

    # Accept routes
    if [[ "$ACCEPT_ROUTES" == "true" ]]; then
        cmd+=" --accept-routes"
    fi

    # SSH
    if [[ "$ENABLE_SSH" == "true" ]]; then
        cmd+=" --ssh"
    fi

    # Execute
    eval "$cmd"

    echo -e "${GREEN}✓${NC} Authenticated with Tailnet"
}

# Get Tailscale IP
get_tailscale_ip() {
    local max_attempts=10
    local attempt=1

    echo -e "${BLUE}ℹ${NC}  Waiting for Tailscale IP..."

    while [[ $attempt -le $max_attempts ]]; do
        TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || true)

        if [[ -n "$TAILSCALE_IP" ]]; then
            echo -e "${GREEN}✓${NC} Tailscale IP: ${CYAN}$TAILSCALE_IP${NC}"
            return 0
        fi

        echo -e "${YELLOW}⏳${NC} Attempt $attempt/$max_attempts..."
        sleep 2
        ((attempt++))
    done

    echo -e "${RED}✗${NC} Failed to get Tailscale IP"
    return 1
}

# Register in NetBox (optional)
register_netbox() {
    if [[ "$REGISTER_DNS" != "true" ]]; then
        return 0
    fi

    if [[ -z "$NETBOX_URL" ]] || [[ -z "$NETBOX_TOKEN" ]]; then
        echo -e "${YELLOW}⚠${NC}  Skipping NetBox registration (NETBOX_URL/TOKEN not set)"
        return 0
    fi

    echo -e "${BLUE}ℹ${NC}  Registering in NetBox..."

    # Create NetBox entry (simplified example)
    curl -X POST "$NETBOX_URL/api/ipam/ip-addresses/" \
        -H "Authorization: Token $NETBOX_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{
            \"address\": \"$TAILSCALE_IP/32\",
            \"dns_name\": \"$HOSTNAME.tailnet\",
            \"description\": \"Tailscale node - auto-provisioned\",
            \"tags\": [\"tailscale\", \"auto-provisioned\"]
        }" 2>/dev/null && \
        echo -e "${GREEN}✓${NC} Registered in NetBox" || \
        echo -e "${YELLOW}⚠${NC}  NetBox registration failed (may already exist)"
}

# Show summary
show_summary() {
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║              ✅ Provisioning Complete!                  ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}📋 Summary:${NC}"
    echo -e "  ${BLUE}Hostname:${NC}     $HOSTNAME"
    echo -e "  ${BLUE}Tailscale IP:${NC} $TAILSCALE_IP"
    [[ -n "$TAGS" ]] && echo -e "  ${BLUE}Tags:${NC}         $TAGS"
    [[ -n "$ADVERTISE_ROUTES" ]] && echo -e "  ${BLUE}Routes:${NC}       $ADVERTISE_ROUTES"
    echo ""
    echo -e "${YELLOW}💡 Quick Tests:${NC}"
    echo -e "  ${CYAN}# Check status${NC}"
    echo -e "  tailscale status"
    echo ""
    echo -e "  ${CYAN}# SSH from another tailnet node${NC}"
    echo -e "  ssh $HOSTNAME"
    echo ""
    echo -e "  ${CYAN}# Ping from another node${NC}"
    echo -e "  ping $HOSTNAME"
    echo ""
}

# Main execution
main() {
    detect_os
    install_tailscale
    authenticate
    get_tailscale_ip
    register_netbox
    show_summary
}

# Run
main
