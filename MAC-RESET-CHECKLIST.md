# Mac Reset / New Mac Setup Checklist

> Run through this in order. Sequence matters — some things depend on others.

---

## Phase 1: Before You Wipe

Make sure these exist and are current before touching the reset button:

- [ ] `sops-age-homelab` is in 1Password HomeLab vault (the 3-line age key block)
- [ ] All SSH keys are in 1Password (they should be — policy enforces this)
- [ ] Dotfiles repo is pushed to GitHub: `cd ~/_code/dotfiles && git status`
- [ ] HomeLab_IaC repos are pushed: `cd ~/_code/HomeLab_IaC && git status` (check each sub-repo)
- [ ] XPipe vault repo is pushed: `cd ~/_code/xpipe-config && git status`
- [ ] XPipe Vault Passphrase is in 1Password (search: "XPipe Vault Passphrase")
- [ ] Any other repos with uncommitted work are pushed

---

## Phase 2: Fresh Mac — First 15 Minutes

### 1. Xcode Command Line Tools
```bash
xcode-select --install
```

### 2. Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
Follow the instructions to add brew to your PATH (it'll tell you the exact commands).

### 3. Core tools
```bash
brew install git age sops ansible 1password-cli
```

### 4. 1Password
- Install the 1Password **app** from the App Store (or brew: `brew install --cask 1password`)
- Sign in with your account
- Enable the SSH agent: Settings → Developer → Use the SSH agent ✓
- Enable the CLI integration: Settings → Developer → Integrate with 1Password CLI ✓

---

## Phase 3: Restore Secrets & SSH Access

### 5. Sign in to 1Password CLI
```bash
eval $(op signin --account my.1password.com)
```

### 6. Restore SOPS age key
```bash
# Clone dotfiles first (needs git, which you have)
git clone git@gitlab.hq.doofus.co:kellen/dotfiles.git ~/_code/dotfiles

# Run the restore script
bash ~/_code/dotfiles/scripts/restore-sops-key.sh
```

If git clone fails (SSH not set up yet), do this first:
```bash
# The 1Password SSH agent handles your keys — just need the config
mkdir -p ~/.ssh
cat > ~/.ssh/config << 'EOF'
Host *
  IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
EOF
chmod 600 ~/.ssh/config
```
Then retry the git clone.

### 7. Install dotfiles
```bash
cd ~/_code/dotfiles
./install.sh
```
Open a new terminal after this — your zshrc is now live.

---

## Phase 4: Homelab Repos

### 8. Clone HomeLab_IaC
```bash
git clone git@gitlab.hq.doofus.co:kellen/HomeLab_IaC.git ~/_code/HomeLab_IaC
cd ~/_code/HomeLab_IaC/infrastructure-core/ansible
ansible-galaxy collection install community.sops
```

### 9. Verify SOPS is working
```bash
# Open a new terminal first so SOPS_AGE_KEY_FILE is set from your zshrc
sops --decrypt ~/_code/HomeLab_IaC/infrastructure-core/ansible/group_vars/all.sops.yml | head -5
```
You should see plaintext YAML with your secrets. If you do, everything is working.

### 10. Test an Ansible run
```bash
cd ~/_code/HomeLab_IaC/infrastructure-core/ansible
ansible-playbook site.yml --tags traefik -l rawls --check
```
`--check` is a dry run — it won't change anything, just verifies connectivity and var loading.

---

## Phase 5: XPipe

XPipe stores connection configs in an encrypted vault backed up to GitLab. SSH keys come
from the 1Password agent — XPipe itself never holds them.

### 11. Install XPipe
```bash
brew install --cask xpipe
```
Or download from xpipe.io (you have a lifetime license — check 1Password or email for the key).

### 12. Restore vault from GitLab
```bash
# XPipe will prompt for a git repo on first launch, OR:
# Open XPipe → Settings → Sync → point at your GitLab vault repo
# URL: git@gitlab.hq.doofus.co:homelab/xpipe-config.git
```

### 13. Enter vault passphrase
- 1Password → HomeLab vault → "XPipe Vault Passphrase"
- Paste when XPipe prompts on first open

### 14. Verify 1Password SSH agent is connected
- XPipe → Settings → SSH → confirm 1Password agent is detected
- Test a connection to any homelab host — it should auth via 1Password without asking for a key

---

## Phase 6: Everything Else

- [ ] **Tailscale**: `brew install --cask tailscale` → sign in
- [ ] **Other repos**: clone from GitLab as needed
- [ ] **System preferences**: dock, hot corners, keyboard shortcuts, etc.
- [ ] Verify `echo $SOPS_AGE_KEY_FILE` in a new terminal prints the key path
- [ ] Verify `echo $EDITOR` prints `nano`

---

## If Something Goes Wrong

### "Can't connect to GitLab"
Check the 1Password SSH agent is running and the `~/.ssh/config` has the agent socket line (Phase 3, step 6).

### "sops: could not decrypt"
Check the key file exists and has the right permissions:
```bash
ls -la ~/.config/sops/age/keys.txt   # should be -rw------- (600)
age-keygen -y ~/.config/sops/age/keys.txt
# should print: age1vhxpve8k0fnyann2j4vmkpwlwnlpckkah98x5ttxgf5ph7qw558qwh4627
```

### "SOPS_AGE_KEY_FILE is not set"
The env var only loads in new terminals after dotfiles are installed. Run:
```bash
source ~/.config/dotfiles/zsh/environment.zsh
```

### Key fingerprint doesn't match
The content in 1Password is wrong or incomplete. The private key line must start with
`AGE-SECRET-KEY-1` and be followed by a long string. Contact yourself via your other device
before the old Mac is wiped.
