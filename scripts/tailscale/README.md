# 🔷 Tailscale Auto-Provisioner

Automatically provision servers, VMs, and containers onto your Tailnet with a single command.

## "Hey You - You're on the Tailnet Now!"

This provisioner handles everything:
- ✅ Installs Tailscale (any OS)
- ✅ Authenticates with your Tailnet
- ✅ Sets hostname
- ✅ Configures tags, routes, SSH
- ✅ Gets Tailscale IP
- ✅ Optional DNS/NetBox registration

## Quick Start

### Basic Provisioning

```bash
# On the target server
curl -fsSL https://raw.githubusercontent.com/UncertainMeow/dotfiles/main/scripts/tailscale/provision.sh | bash -s jeremy

# Or clone dotfiles first
git clone https://github.com/UncertainMeow/dotfiles.git
cd dotfiles/scripts/tailscale
./provision.sh jeremy
```

### With Auth Key (Unattended)

```bash
# Set auth key
export TAILSCALE_AUTHKEY="tskey-auth-xxxxx"

# Provision
./provision.sh my-server
```

### Production Server with Tags and Routes

```bash
./provision.sh \
  --authkey tskey-auth-xxxxx \
  --tags tag:server,tag:prod \
  --routes 10.0.1.0/24 \
  web-01
```

### Full-Featured Setup

```bash
./provision.sh \
  --authkey tskey-auth-xxxxx \
  --tags tag:server,tag:database \
  --routes 10.0.1.0/24,10.0.2.0/24 \
  --accept-routes \
  --register-dns \
  database-01
```

## Options

| Option | Description |
|--------|-------------|
| `-k, --authkey KEY` | Tailscale auth key (or set `TAILSCALE_AUTHKEY` env) |
| `-t, --tags TAGS` | Comma-separated tags: `tag:server,tag:prod` |
| `-r, --routes ROUTES` | Advertise routes: `10.0.0.0/24,192.168.1.0/24` |
| `-a, --accept-routes` | Accept routes from other nodes |
| `--no-ssh` | Disable Tailscale SSH |
| `--register-dns` | Register in NetBox (requires `NETBOX_URL`/`TOKEN`) |

## Authentication Keys

Generate auth keys at: https://login.tailscale.com/admin/settings/keys

**For Servers (long-lived):**
- Reusable: ✅
- Ephemeral: ❌
- Expiry: 90 days or longer

**For Containers (short-lived):**
- Reusable: ✅
- Ephemeral: ✅ (auto-cleanup)
- Expiry: 1 day

**With ACLs:**
- Add appropriate tags: `tag:server`, `tag:container`, etc.

## Remote Provisioning

Provision remote servers via SSH:

```bash
# Copy script to remote server
scp provision.sh user@server:~/

# Run via SSH
ssh user@server "TAILSCALE_AUTHKEY=tskey-xxx ~/provision.sh web-server"

# Or one-liner
ssh user@server 'curl -fsSL https://raw.githubusercontent.com/UncertainMeow/dotfiles/main/scripts/tailscale/provision.sh | bash -s - web-server'
```

## Cloud-Init Integration

For VMs (Proxmox, AWS, GCP, Azure):

```yaml
#cloud-config
runcmd:
  - curl -fsSL https://tailscale.com/install.sh | sh
  - |
    tailscale up \
      --authkey=tskey-auth-xxxxx \
      --hostname=my-vm \
      --advertise-tags=tag:vm,tag:cloud \
      --ssh
```

See [`cloud-init-example.yaml`](./cloud-init-example.yaml) for full template.

## Docker Compose Integration

Run containerized services on Tailnet using sidecar pattern:

```yaml
services:
  app-tailscale:
    image: tailscale/tailscale:latest
    environment:
      - TS_AUTHKEY=${TAILSCALE_AUTHKEY}
      - TS_HOSTNAME=my-app
    volumes:
      - /dev/net/tun:/dev/net/tun
    cap_add:
      - NET_ADMIN

  app:
    image: myapp:latest
    network_mode: service:app-tailscale
```

See [`docker-compose-example.yaml`](./docker-compose-example.yaml) for full examples.

## NetBox Integration

Register provisioned nodes in NetBox automatically:

```bash
# Set NetBox credentials
export NETBOX_URL="https://netbox.example.com"
export NETBOX_TOKEN="your-api-token"

# Provision with DNS registration
./provision.sh --register-dns web-01
```

Creates NetBox entries with:
- IP address: Tailscale IP
- DNS name: `hostname.tailnet`
- Tags: `tailscale`, `auto-provisioned`

## Aliases for ~/.zshrc

Add these to your dotfiles for quick access:

```bash
# Tailscale provisioning
alias tsprovision='~/dotfiles/scripts/tailscale/provision.sh'
alias ts-jeremy='tsprovision jeremy'  # Quick test server

# Remote provisioning
tsremote() {
    local host=$1
    local name=$2
    ssh "$host" "curl -fsSL https://raw.githubusercontent.com/UncertainMeow/dotfiles/main/scripts/tailscale/provision.sh | bash -s - $name"
}
```

## Workflow Examples

### New Homelab Server

```bash
# Physical server you just racked
./provision.sh \
  --tags tag:server,tag:homelab \
  --routes 10.0.0.0/16 \
  --ssh \
  lab-server-01
```

### Quick Test VM

```bash
# Ephemeral VM for testing
./provision.sh --tags tag:test test-vm-$(date +%s)
```

### Container Fleet

```bash
# Deploy 5 nginx containers
for i in {1..5}; do
    docker run -d \
        --name nginx-$i \
        -e TS_AUTHKEY=$TAILSCALE_AUTHKEY \
        -e TS_HOSTNAME=nginx-$i \
        tailscale/nginx
done
```

### Database Server (Private)

```bash
# Database with no internet exposure
./provision.sh \
  --tags tag:database,tag:private \
  --no-ssh \
  postgres-01
```

## Troubleshooting

### "Auth key required"
- Generate key at https://login.tailscale.com/admin/settings/keys
- Set `TAILSCALE_AUTHKEY` environment variable
- Or pass with `--authkey` flag

### "Failed to get Tailscale IP"
- Check Tailscale is running: `systemctl status tailscaled`
- Verify authentication: `tailscale status`
- Check firewall allows UDP port 41641

### "NetBox registration failed"
- Verify `NETBOX_URL` and `NETBOX_TOKEN` are set
- Check API token permissions
- May indicate node already registered (not an error)

## Security Notes

- **Auth keys are secrets** - Never commit to git
- Use short-lived ephemeral keys for containers
- Use tags and ACLs to restrict access
- Rotate keys regularly
- Consider using Tailscale SSH instead of password auth

## Related

- [Tailscale Documentation](https://tailscale.com/kb/)
- [Tailscale ACLs](https://tailscale.com/kb/1018/acls/)
- [Tailscale SSH](https://tailscale.com/kb/1193/tailscale-ssh/)
- [NetBox API](https://netbox.readthedocs.io/)
