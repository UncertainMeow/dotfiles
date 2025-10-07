# Work Computer Security Guide

## Overview

This guide covers security considerations for using these dotfiles on a work computer with sensitive data.

## Quick Start: Work-Safe Installation

```bash
git clone https://github.com/UncertainMeow/dotfiles.git
cd dotfiles
./install-work.sh  # Uses work-safe mode (no Hammerspoon)
```

## What's Different in Work Mode

| Feature | Regular Install | Work Install |
|---------|----------------|--------------|
| **Hotkeys (⌘+Shift+D)** | ✅ Via Hammerspoon | ❌ Use `dev` command instead |
| **Accessibility permissions** | Required | Not required |
| **Container launcher** | ✅ Included | ✅ Included |
| **Shell aliases/functions** | ✅ Included | ✅ Included |
| **Terminal configs** | ✅ Included | ✅ Included |

**Bottom line:** Same functionality, just type `dev` instead of pressing a hotkey.

## Security Analysis of Components

### ✅ Safe for Work (No Special Permissions)

**zsh configuration:**
- Standard shell configuration
- No system access beyond normal shell operations
- Isolated to your user account

**tmux:**
- Terminal multiplexer
- No network access or special permissions
- Standard development tool

**Ghostty/Alacritty:**
- Terminal emulators
- Standard applications
- No special permissions required

**Docker containers:**
- Isolated environments
- Can't access host system unless explicitly mounted
- Industry-standard isolation

**Shell scripts (validate-*.sh, sync-*.sh):**
- Simple file operations
- No network access
- Auditable (plain text)

### ⚠️ Requires Consideration

**Hammerspoon (in regular install):**
- ❌ Requires Accessibility permissions (can monitor all input)
- ❌ Can execute arbitrary shell commands
- ❌ Runs continuously in background
- ⚠️ Many companies prohibit automation tools with these permissions
- **Recommendation:** Use work-safe install instead

**1Password SSH agent:**
- ✅ Commercial security tool
- ✅ Likely already approved by your company
- ✅ More secure than storing SSH keys on disk
- Check: Verify it's in your approved software list

**Docker Desktop:**
- ✅ Industry-standard containerization
- ⚠️ Check if approved (many companies have it pre-installed)
- ⚠️ Can access files you mount into containers

## What Data Could Be Exposed

### Shell History

Your `~/.zsh_history` might contain:
- Accidentally pasted passwords/API keys
- Internal hostnames and IP addresses
- Proprietary commands or workflows
- Database connection strings

**Mitigation:**

```bash
# Add to ~/dotfiles-config/zsh/history.zsh
setopt HIST_IGNORE_SPACE  # Don't save commands starting with space
export HISTORY_IGNORE="(aws *|export *SECRET*|export *KEY*|curl *://*/token*)"
```

**Best practice:** Prefix sensitive commands with a space:
```bash
 aws s3 ls s3://secret-bucket --profile work  # Note the leading space
```

### Git Configuration

Commits might leak:
- Work email address
- Internal repository URLs
- Work-related commit messages

**Mitigation:**

```bash
# In ~/dotfiles/config/zsh/git-config.zsh (create if needed)
# Use conditional git config for work directories
git config --global includeIf.gitdir:~/work/.path ~/work/.gitconfig

# In ~/work/.gitconfig
[user]
    name = Your Name
    email = you@workdomain.com
    signingkey = <work-gpg-key>
```

### SSH Configuration

`~/.ssh/config` might contain:
- Internal hostnames
- Jump box configurations
- Private network details

**Mitigation:**
- Don't commit work-specific SSH config to the dotfiles repo
- Use `~/.ssh/config.work` and include it:

```bash
# In your ~/.ssh/config (after dotfiles install)
Include config.work  # Not tracked in git
```

### Environment Variables

Shell might expose:
- AWS credentials
- API tokens
- Internal URLs

**Mitigation:**

```bash
# Use ~/.zshrc.local for work-specific secrets (not tracked in git)
export WORK_API_KEY="..."
export INTERNAL_ENDPOINT="..."

# In main ~/.zshrc, ensure this line exists:
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
```

## Container Security Best Practices

### Risks

1. **Volume mounts** - Containers can access mounted directories
2. **Network exposure** - Containers can expose ports
3. **Image integrity** - Malicious container images

### Mitigations

**Don't mount sensitive work directories:**

```bash
# ❌ BAD - exposes work files to container
docker run -v ~/work:/work ubuntu

# ✅ GOOD - only mount specific test directory
docker run -v ~/test-data:/data ubuntu
```

**Use content trust:**

```bash
# Add to ~/dotfiles-config/zsh/environment.zsh
export DOCKER_CONTENT_TRUST=1  # Require signed images only
```

**Avoid privileged containers:**

```bash
# ❌ BAD - full host access
docker run --privileged ubuntu

# ✅ GOOD - limited permissions
docker run ubuntu
```

**Review container definitions:**

```bash
# Check what the environment launcher will run
cat ~/.config/dev-environments/containers.yaml
```

## Parallels Integration (Work-Approved Alternative)

Since you have Parallels (approved by your company), you can use it for isolation:

```bash
# Add to ~/dotfiles-config/zsh/functions.zsh

# Launch Windows VM for Excel work
work-windows() {
    prlctl start "Windows 11" && \
    prlctl console "Windows 11"
}

# Launch Linux dev VM (completely isolated)
work-dev() {
    prlctl start "Ubuntu Dev" && \
    prlctl exec "Ubuntu Dev" /bin/bash
}

# List all VMs
work-vms() {
    prlctl list -a
}
```

**Benefits:**
- Parallels is already approved
- VMs are more isolated than containers
- Can snapshot VM state
- Familiar to IT department

## Files That Should NEVER Be Committed

Add to `.gitignore`:

```
# Work-specific
.zshrc.local
.zshrc.work
.ssh/config.work
**/work-*
*.work

# Credentials
.env
.env.*
.aws/credentials
.ssh/id_*
.ssh/*.pem
*.key
*.p12
*.pfx

# Company-specific
**/internal-*
**/company-*
```

## Recommended .zshrc.local Template

Create `~/.zshrc.local` (not tracked in git):

```bash
#!/usr/bin/env zsh
# Machine-specific configuration (not tracked in git)

# Work mode flag
export WORK_MODE=true

# Work-specific environment
export WORK_EMAIL="you@company.com"
export WORK_ORG="Your Company"

# Don't save sensitive commands to history
export HISTORY_IGNORE="(aws *|export *SECRET*|export *KEY*|curl *://*/token*|ssh *@10.*)"

# Work-specific aliases
alias work-vpn='open -a "Cisco AnyConnect"'
alias work-jump='ssh jumpbox.internal.company.com'

# Work git config
git config --global user.email "$WORK_EMAIL"
git config --global user.name "$WORK_ORG"

# Parallels shortcuts (if installed)
if command -v prlctl >/dev/null 2>&1; then
    alias win='prlctl start "Windows 11" && prlctl console "Windows 11"'
    alias ubuntu='prlctl start "Ubuntu Dev" && prlctl console "Ubuntu Dev"'
fi
```

## Audit Checklist for Work Computers

Before using dotfiles on work computer:

- [ ] Used `install-work.sh` (not regular `install.sh`)
- [ ] No Hammerspoon installed (check `/Applications/Hammerspoon.app`)
- [ ] Created `.zshrc.local` for work-specific settings
- [ ] Added work-specific entries to `.gitignore`
- [ ] Configured separate git email for work directories
- [ ] Reviewed all shell scripts in `dotfiles/scripts/`
- [ ] Set up `HISTORY_IGNORE` for sensitive commands
- [ ] Don't mount work directories into containers
- [ ] Enabled Docker content trust (`DOCKER_CONTENT_TRUST=1`)
- [ ] Checked with IT if Docker/terminals are approved
- [ ] Using 1Password or similar for SSH keys (not raw files)

## What to Ask Your IT/Security Team

1. **Docker Desktop** - "Is Docker Desktop on the approved software list?"
2. **Terminal emulators** - "Are Ghostty and Alacritty approved, or should I use built-in Terminal?"
3. **Automation tools** - "Is Hammerspoon permitted?" (if yes, use regular install)
4. **Container policies** - "Are there restrictions on running containers locally?"
5. **SSH key storage** - "Should I use 1Password SSH agent or another key management solution?"

## Red Flags to Watch For

**Don't commit if:**
- File contains actual passwords or API keys
- Contains internal hostnames or IP ranges
- Has company-specific configuration
- Includes customer data or PII

**Don't run if:**
- Script downloads and executes remote code (`curl | bash`)
- Requires `sudo` for normal operations
- Wants Accessibility permissions
- Runs with `--privileged` flag

## Regular Security Maintenance

**Monthly:**
- Review `~/.zsh_history` for accidentally saved credentials
- Check `git log` in dotfiles repo for sensitive commits
- Audit running Docker containers (`docker ps`)
- Review SSH config for outdated entries

**When leaving company:**
- Delete `~/.zshrc.local`
- Delete `~/.ssh/config.work`
- Clear shell history: `rm ~/.zsh_history`
- Remove work-specific git config

## Summary: Work-Safe Configuration

**Safe approach:**
1. Use `install-work.sh` (no Hammerspoon)
2. Keep work configs in `.zshrc.local` (not in git)
3. Use Parallels for VMs (already approved)
4. Use Docker for containers (isolated, read-only mounts)
5. Never commit credentials or internal details
6. Prefix sensitive commands with space (not saved to history)

**Result:** Same productivity benefits, no security concerns.
