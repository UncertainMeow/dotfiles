#!/usr/bin/env bash
# restore-sops-key.sh
# Restores the SOPS age private key from 1Password after a fresh Mac setup.
#
# Run this early in Mac setup — before trying to run any Ansible playbooks.
#
# Prerequisites:
#   - 1Password app installed and signed in
#   - 1Password CLI installed: brew install 1password-cli
#   - age installed: brew install age sops

set -euo pipefail

KEYS_DIR="$HOME/.config/sops/age"
KEYS_FILE="$KEYS_DIR/keys.txt"
OP_ACCOUNT="my.1password.com"

# The backup secure note in the Private vault (contains full key block)
OP_BACKUP_REF="op://Private/l5ze4c4ul6aicwzm7nsqt4gfom/text"

# Expected public key — used to verify the restore worked
EXPECTED_PUBKEY="age1vhxpve8k0fnyann2j4vmkpwlwnlpckkah98x5ttxgf5ph7qw558qwh4627"

echo ""
echo "=== SOPS Age Key Restore ==="
echo ""

# --- Check prerequisites ---

if ! command -v op &>/dev/null; then
  echo "ERROR: 1Password CLI not installed."
  echo "  brew install 1password-cli"
  exit 1
fi

if ! command -v age-keygen &>/dev/null; then
  echo "ERROR: age not installed."
  echo "  brew install age sops"
  exit 1
fi

# --- Check 1Password auth ---

echo "Checking 1Password authentication..."
if ! op account list 2>/dev/null | grep -q "$OP_ACCOUNT"; then
  echo ""
  echo "Not signed in to $OP_ACCOUNT. Sign in first:"
  echo "  eval \$(op signin --account $OP_ACCOUNT)"
  exit 1
fi

if ! op vault list --account "$OP_ACCOUNT" &>/dev/null; then
  echo ""
  echo "1Password session expired. Re-authenticate:"
  echo "  eval \$(op signin --account $OP_ACCOUNT)"
  exit 1
fi

echo "  ✓ Authenticated to $OP_ACCOUNT"
echo ""

# --- Check if key already exists ---

if [[ -f "$KEYS_FILE" ]]; then
  CURRENT_PUBKEY=$(age-keygen -y "$KEYS_FILE" 2>/dev/null || echo "invalid")
  if [[ "$CURRENT_PUBKEY" == "$EXPECTED_PUBKEY" ]]; then
    echo "  ✓ Key already present and valid at $KEYS_FILE"
    echo "  Nothing to do."
    exit 0
  else
    echo "  ! Key exists at $KEYS_FILE but doesn't match expected public key."
    echo "    Current:  $CURRENT_PUBKEY"
    echo "    Expected: $EXPECTED_PUBKEY"
    echo ""
    read -rp "Overwrite with key from 1Password? [y/N] " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
  fi
fi

# --- Create directory ---

mkdir -p "$KEYS_DIR"
chmod 700 "$KEYS_DIR"

# --- Pull from 1Password and extract the key line ---
# The stored note contains extra text and leading whitespace from when it was saved.
# We extract just the AGE-SECRET-KEY-1... line, which is what age actually needs.

echo "Pulling key from 1Password..."
echo ""

RAW=$(op read "$OP_BACKUP_REF" --account "$OP_ACCOUNT" 2>/dev/null || echo "")

if [[ -z "$RAW" ]]; then
  echo "ERROR: Could not read from 1Password. Check that you're signed in and the item exists."
  echo ""
  echo "Manual restore:"
  echo "  1. Open 1Password → Private vault → item ID l5ze4c4ul6aicwzm7nsqt4gfom"
  echo "  2. Find the line starting with AGE-SECRET-KEY-1..."
  echo "  3. mkdir -p $KEYS_DIR && chmod 700 $KEYS_DIR"
  echo "  4. Write that line to $KEYS_FILE"
  echo "  5. chmod 600 $KEYS_FILE"
  echo "  6. Verify: age-keygen -y $KEYS_FILE"
  exit 1
fi

# Extract the private key line (starts with AGE-SECRET-KEY-1, strip any whitespace)
PRIVATE_KEY=$(echo "$RAW" | grep -o 'AGE-SECRET-KEY-1[A-Z0-9]*' | head -1)

if [[ -z "$PRIVATE_KEY" ]]; then
  echo "ERROR: Could not find AGE-SECRET-KEY-1... line in the stored note."
  echo "The 1Password item may be corrupted or in an unexpected format."
  echo ""
  echo "Raw content retrieved (first 200 chars):"
  echo "${RAW:0:200}"
  exit 1
fi

echo "  ✓ Private key extracted from 1Password"

# Reconstruct a clean keys.txt
cat > "$KEYS_FILE" << EOF
# created: 2026-03-22T12:43:26-04:00
# public key: ${EXPECTED_PUBKEY}
${PRIVATE_KEY}
EOF

chmod 600 "$KEYS_FILE"

# --- Verify ---

echo ""
echo "Verifying restored key..."
RESTORED_PUBKEY=$(age-keygen -y "$KEYS_FILE" 2>/dev/null || echo "failed")

if [[ "$RESTORED_PUBKEY" == "$EXPECTED_PUBKEY" ]]; then
  echo "  ✓ Key restored and verified."
  echo "  Public key: $RESTORED_PUBKEY"
  echo "  Key file:   $KEYS_FILE"
  echo ""
  echo "You're good. Run Ansible normally — SOPS_AGE_KEY_FILE is set in your zshrc."
else
  echo ""
  echo "ERROR: Restored key does not match expected public key."
  echo "  Got:      $RESTORED_PUBKEY"
  echo "  Expected: $EXPECTED_PUBKEY"
  echo ""
  echo "Something went wrong with the extraction. Try manually:"
  echo "  1. op read '$OP_BACKUP_REF' --account $OP_ACCOUNT"
  echo "  2. Find the AGE-SECRET-KEY-1... line and write it to $KEYS_FILE"
  rm -f "$KEYS_FILE"
  exit 1
fi
