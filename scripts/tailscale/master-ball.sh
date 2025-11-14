#!/usr/bin/env bash
# =============================================================================
# MASTER-BALL - Remote Tailscale Provisioning
# =============================================================================
# "The Master Ball never fails!" - Deploy Tailscale to remote servers
#
# Usage:
#   master-ball.sh user@server jeremy
#   master-ball.sh user@server web-01 --tags tag:server,tag:prod

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Check arguments
if [[ $# -lt 2 ]]; then
    cat << EOF
${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}
${PURPLE}║     🔴 MASTER-BALL - Remote Tailscale Provisioning    ║${NC}
${PURPLE}║     "The Master Ball never fails!"                     ║${NC}
${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}

${YELLOW}Usage:${NC}
  $0 <ssh-target> <hostname> [pokeball-options]

${YELLOW}Examples:${NC}
  # Basic capture
  $0 user@192.168.1.100 jeremy

  # Production server with tags
  $0 root@server.example.com web-01 --tags tag:server,tag:prod

  # Full featured
  $0 user@10.0.1.50 database-01 \\
    --authkey tskey-xxx \\
    --tags tag:database \\
    --routes 10.0.1.0/24

${YELLOW}What it does:${NC}
  1. SSHs into remote server
  2. Downloads pokeball.sh provisioner
  3. Runs it with your specified options
  4. Server appears on your Tailnet!

${YELLOW}Tip:${NC} Set TAILSCALE_AUTHKEY env variable to avoid passing --authkey

EOF
    exit 1
fi

SSH_TARGET="$1"
HOSTNAME="$2"
shift 2
POKEBALL_ARGS="$*"

echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║     🔴 Deploying Master Ball to ${HOSTNAME}...            ║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}🎯 Target:${NC} $SSH_TARGET"
echo -e "${BLUE}📛 Hostname:${NC} $HOSTNAME"
[[ -n "$POKEBALL_ARGS" ]] && echo -e "${BLUE}⚙️  Options:${NC} $POKEBALL_ARGS"
echo ""

# Check SSH connectivity
echo -e "${BLUE}🔍 Testing SSH connection...${NC}"
if ! ssh -o ConnectTimeout=5 -o BatchMode=yes "$SSH_TARGET" "echo ''" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  SSH keys not set up. You may be prompted for password.${NC}"
fi

# Deploy and run pokeball
echo -e "${BLUE}🚀 Deploying pokeball.sh to remote server...${NC}"

POKEBALL_URL="https://raw.githubusercontent.com/UncertainMeow/dotfiles/main/scripts/tailscale/pokeball.sh"
AUTHKEY_ENV=""
[[ -n "${TAILSCALE_AUTHKEY:-}" ]] && AUTHKEY_ENV="TAILSCALE_AUTHKEY=$TAILSCALE_AUTHKEY"

ssh "$SSH_TARGET" "bash -s -- $HOSTNAME $POKEBALL_ARGS" <<EOF
set -euo pipefail

echo "📥 Downloading pokeball.sh..."
curl -fsSL "$POKEBALL_URL" -o /tmp/pokeball.sh
chmod +x /tmp/pokeball.sh

echo "🔴 Throwing Master Ball at $HOSTNAME..."
$AUTHKEY_ENV /tmp/pokeball.sh $HOSTNAME $POKEBALL_ARGS

rm /tmp/pokeball.sh
EOF

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        ✅ $HOSTNAME Captured Successfully!              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}💡 Next steps:${NC}"
echo -e "  ${BLUE}# Check it appeared on your Tailnet${NC}"
echo -e "  tailscale status | grep $HOSTNAME"
echo ""
echo -e "  ${BLUE}# SSH via Tailscale${NC}"
echo -e "  ssh $HOSTNAME"
echo ""
