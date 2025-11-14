# ⚡ Tailscale Pokemon Provisioner

**"Gotta catch 'em all!"** - Automatically provision servers, VMs, and containers onto your Tailnet.

## The Pokemon Squad

| Script | Description | Usage |
|--------|-------------|-------|
| 🔴 **pokeball.sh** | Local provisioning | Capture servers you have access to |
| 🔴 **mines-now.sh** | Symlink to pokeball | "This server is mine now!" |
| ⚫ **master-ball.sh** | Remote provisioning | Never fails - capture any server via SSH |
| ⚡ **choose-you.sh** | Cloud-init generator | "I choose you!" - Create VMs |
| ⚡ **go-dockahu.sh** | Docker compose generator | "Go Pikachu!" - Containerize services |

## Quick Start

### 🔴 Pokeball - Local Provisioning

Throw a Pokeball at a server you're logged into:

```bash
# Clone dotfiles
git clone https://github.com/UncertainMeow/dotfiles.git
cd dotfiles/scripts/tailscale

# Basic capture
./pokeball.sh jeremy

# With auth key (unattended)
export TAILSCALE_AUTHKEY="tskey-auth-xxxxx"
./pokeball.sh my-server

# Production server with tags
./pokeball.sh \
  --authkey tskey-auth-xxxxx \
  --tags tag:server,tag:prod \
  --routes 10.0.1.0/24 \
  web-01
```

### ⚫ Master Ball - Remote Provisioning

"The Master Ball never fails!" - Capture remote servers via SSH:

```bash
# Basic remote capture
./master-ball.sh user@192.168.1.100 jeremy

# Production server
./master-ball.sh root@server.example.com web-01 \
  --tags tag:server,tag:prod

# Full featured
./master-ball.sh user@10.0.1.50 database-01 \
  --authkey tskey-xxx \
  --tags tag:database \
  --routes 10.0.1.0/24
```

Master Ball will:
1. SSH into the remote server
2. Download pokeball.sh
3. Run it with your options
4. Clean up after itself

### ⚡ Choose-You - Cloud-Init Generator

"I choose you!" - Generate cloud-init configs for VMs:

```bash
./choose-you.sh

# Interactive prompts:
# - VM hostname
# - Tailscale auth key
# - Tags
# - Username
# - SSH keys
# - Timezone
# - Install dotfiles?

# Generates cloud-init-<hostname>.yaml
```

Use the generated file with:
- **Proxmox**: `qm set <vmid> --cicustom user=local:snippets/cloud-init.yaml`
- **AWS/GCP/Azure**: As user-data
- **Multipass**: `multipass launch --cloud-init cloud-init.yaml`

### ⚡ Go-Dockahu - Docker Compose Generator

"Go Pikachu!" - Generate docker-compose configs with Tailscale sidecars:

```bash
./go-dockahu.sh

# Interactive prompts:
# - Service type (web/database/monitoring/custom)
# - Service name
# - Docker image
# - Tailscale tags
# - Local ports
# - Volumes

# Generates docker-compose-<service>.yaml
```

Deploy with:
```bash
echo 'TAILSCALE_AUTHKEY=tskey-auth-xxx' > .env
docker-compose -f docker-compose-<service>.yaml up -d
```

## Options (pokeball.sh & master-ball.sh)

| Option | Description |
|--------|-------------|
| `-k, --authkey KEY` | Tailscale auth key (or set `TAILSCALE_AUTHKEY` env) |
| `-t, --tags TAGS` | Comma-separated tags: `tag:server,tag:prod` |
| `-r, --routes ROUTES` | Advertise routes: `10.0.0.0/24,192.168.1.0/24` |
| `-a, --accept-routes` | Accept routes from other nodes |
| `--no-ssh` | Disable Tailscale SSH |
| `--register-dns` | Register in NetBox (requires `NETBOX_URL`/`TOKEN`) |

## Authentication Keys

Generate at: https://login.tailscale.com/admin/settings/keys

**For Servers (long-lived Pokeballs):**
- Reusable: ✅
- Ephemeral: ❌
- Expiry: 90 days or longer

**For Containers (disposable Pokeballs):**
- Reusable: ✅
- Ephemeral: ✅ (auto-cleanup)
- Expiry: 1 day

**With ACLs:**
- Add appropriate tags: `tag:server`, `tag:container`, etc.

## Battle Strategies (Use Cases)

### 🏠 New Homelab Server

```bash
# Physical server you just racked
./pokeball.sh \
  --tags tag:server,tag:homelab \
  --routes 10.0.0.0/16 \
  --ssh \
  lab-server-01
```

### 🧪 Quick Test VM

```bash
# Choose-You for automated VM
./choose-you.sh
# Follow prompts, then deploy VM with generated cloud-init
```

### 🐋 Container Fleet

```bash
# Generate compose file
./go-dockahu.sh
# Creates docker-compose-<service>.yaml

# Deploy
docker-compose -f docker-compose-my-app.yaml up -d
```

### 🌐 Remote Server Capture

```bash
# Capture a remote server via SSH
./master-ball.sh user@remote-server.com web-server \
  --tags tag:server,tag:web
```

### 🗄️ Database Server (Private)

```bash
# Database with no internet exposure
./pokeball.sh \
  --tags tag:database,tag:private \
  --no-ssh \
  postgres-01
```

## Aliases for ~/.zshrc

Add these to your dotfiles for quick access:

```bash
# Tailscale Pokemon
alias pokeball='~/dotfiles/scripts/tailscale/pokeball.sh'
alias masterball='~/dotfiles/scripts/tailscale/master-ball.sh'
alias chooseyou='~/dotfiles/scripts/tailscale/choose-you.sh'
alias godockahu='~/dotfiles/scripts/tailscale/go-dockahu.sh'

# Quick captures
alias catch-jeremy='pokeball jeremy'

# Remote capture
catch-remote() {
    local host=$1
    local name=$2
    shift 2
    masterball "$host" "$name" "$@"
}
```

## Pokemon Evolution Guide

### Level 1: Single Server
```bash
./pokeball.sh my-server
```

### Level 2: Remote Servers
```bash
./master-ball.sh user@server my-server
```

### Level 3: VM Fleet (Cloud-Init)
```bash
./choose-you.sh
# Deploy 10 VMs with same config
```

### Level 4: Container Swarm (Docker)
```bash
./go-dockahu.sh
# Deploy containers across multiple hosts
```

### Level 5: Full Automation
```bash
# Combine with Terraform, Ansible, etc.
# Auto-provision entire infrastructure
```

## Troubleshooting

### "Auth key required"
- Generate key at https://login.tailscale.com/admin/settings/keys
- Set `TAILSCALE_AUTHKEY` environment variable
- Or pass with `--authkey` flag

### "Failed to capture (Pokeball missed!)"
- Check Tailscale is running: `systemctl status tailscaled`
- Verify authentication: `tailscale status`
- Check firewall allows UDP port 41641

### "Master Ball can't connect"
- Verify SSH access: `ssh user@server`
- Check SSH keys are set up
- Try with password authentication

### "NetBox registration failed"
- Verify `NETBOX_URL` and `NETBOX_TOKEN` are set
- Check API token permissions
- May indicate node already registered (not an error)

## Security Notes

- **Auth keys are secrets** - Never commit to git
- Use ephemeral keys for containers (they self-destruct)
- Use tags and ACLs to restrict access
- Rotate keys regularly
- Consider using Tailscale SSH instead of password auth

## Example Workflows

### New Proxmox VM
```bash
# 1. Generate cloud-init
./choose-you.sh
# Name: web-01, follow prompts

# 2. Upload to Proxmox
scp cloud-init-web-01.yaml proxmox:/var/lib/vz/snippets/

# 3. Create VM with cloud-init
qm create 100 --name web-01 --cicustom user=local:snippets/cloud-init-web-01.yaml

# 4. Start VM - it auto-joins Tailnet!
qm start 100

# 5. Access via Tailscale
ssh web-01
```

### Docker Swarm on Tailnet
```bash
# 1. Generate compose files for each service
./go-dockahu.sh  # nginx
./go-dockahu.sh  # postgres
./go-dockahu.sh  # redis

# 2. Deploy across swarm
docker stack deploy -c docker-compose-nginx.yaml web
docker stack deploy -c docker-compose-postgres.yaml db
docker stack deploy -c docker-compose-redis.yaml cache

# 3. All services accessible via Tailscale hostnames
curl http://nginx
psql postgres://postgres:5432
redis-cli -h redis
```

## Related

- [Tailscale Documentation](https://tailscale.com/kb/)
- [Tailscale ACLs](https://tailscale.com/kb/1018/acls/)
- [Tailscale SSH](https://tailscale.com/kb/1193/tailscale-ssh/)
- [Cloud-Init Docs](https://cloudinit.readthedocs.io/)
- [Docker Compose Docs](https://docs.docker.com/compose/)

---

**"Gotta provision 'em all!"** ⚡
