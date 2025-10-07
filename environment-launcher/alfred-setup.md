# Alfred PowerPack Setup for Environment Launcher

Alfred PowerPack is already installed and perfect for this use case.

## Quick Setup (5 minutes)

### Workflow 1: Dev Environment Launcher

1. **Open Alfred Preferences**
2. **Workflows tab → + (bottom left) → Blank Workflow**
3. **Name:** "Dev Environment Launcher"
4. **Add Hotkey trigger:**
   - Right-click canvas → Inputs → Hotkey
   - Set: ⌘⇧D
   - Argument: None
   - Connect to...
5. **Add Script action:**
   - Right-click canvas → Actions → Run Script
   - Language: `/bin/bash`
   - Script:
     ```bash
     export PATH=/usr/local/bin:/opt/homebrew/bin:$PATH

     # Open in Ghostty (or Terminal)
     if command -v ghostty >/dev/null; then
       open -a Ghostty -n --args -e ~/.local/bin/dev-launcher
     else
       osascript -e 'tell application "Terminal"
         activate
         do script "~/.local/bin/dev-launcher"
       end tell'
     fi
     ```
6. **Connect hotkey to script** (drag the node)
7. **Save**

### Workflow 2: Dev Command (Keyword Trigger)

Even better - type `dev` in Alfred to open menu:

1. **Create new Workflow:** "Dev Commands"
2. **Add Keyword Input:**
   - Right-click → Inputs → Keyword
   - Keyword: `dev`
   - Title: "Dev Environment"
   - Argument: None
3. **Add Script action** (same as above)
4. **Connect nodes**

### Workflow 3: Docker Cleanup

1. **Create workflow:** "Docker Cleanup"
2. **Add Keyword Input:**
   - Keyword: `docker clean`
   - Or add Hotkey: ⌘⇧C
3. **Add Script action:**
   ```bash
   export PATH=/usr/local/bin:/opt/homebrew/bin:$PATH
   docker system prune -f

   # Show notification
   osascript -e 'display notification "Docker cleanup complete" with title "Dev Environment"'
   ```

## Advanced: Alfred List Filter with Container Selection

Alfred can show a searchable list of environments:

### Interactive Container Menu

1. **Create workflow:** "Dev Environments"
2. **Add Keyword Input:**
   - Keyword: `dev`
   - Argument: Optional
3. **Add List Filter:**
   - Right-click → Inputs → List Filter
   - Add items:
     - Title: "🐧 NixOS Learning Environment"
       Subtitle: "Interactive NixOS shell"
       Arg: `nixos`
     - Title: "☸️ K3s Kubernetes Cluster"
       Subtitle: "Lightweight K8s for testing"
       Arg: `k3s`
     - Title: "🐍 Python Development"
       Subtitle: "Python 3.12 environment"
       Arg: `python`
     - Title: "🟢 Node.js Development"
       Subtitle: "Node.js LTS environment"
       Arg: `nodejs`
     - Title: "🦀 Rust Development"
       Subtitle: "Rust stable toolchain"
       Arg: `rust`
     - Title: "💻 Parallels - Windows"
       Subtitle: "Launch Windows VM"
       Arg: `pvm-windows`
     - Title: "🐧 Parallels - Ubuntu"
       Subtitle: "Launch Ubuntu VM"
       Arg: `pvm-ubuntu`
     - Title: "🧹 Docker Cleanup"
       Subtitle: "Remove unused containers/images"
       Arg: `cleanup`
4. **Add Script action:**
   ```bash
   export PATH=/usr/local/bin:/opt/homebrew/bin:$PATH

   case "{query}" in
     nixos)
       osascript -e 'tell application "Terminal"
         do script "docker run -it nixos/nix"
       end tell'
       ;;
     k3s)
       osascript -e 'tell application "Terminal"
         do script "docker run -it rancher/k3s:latest"
       end tell'
       ;;
     python)
       osascript -e 'tell application "Terminal"
         do script "docker run -it python:3.12"
       end tell'
       ;;
     nodejs)
       osascript -e 'tell application "Terminal"
         do script "docker run -it node:lts"
       end tell'
       ;;
     rust)
       osascript -e 'tell application "Terminal"
         do script "docker run -it rust:latest"
       end tell'
       ;;
     pvm-windows)
       prlctl start "Windows 11" && prlctl console "Windows 11"
       ;;
     pvm-ubuntu)
       prlctl start "Ubuntu Dev" && prlctl console "Ubuntu Dev"
       ;;
     cleanup)
       docker system prune -f
       osascript -e 'display notification "Cleanup complete" with title "Docker"'
       ;;
   esac
   ```

## Even Better: Use Existing dev-launcher Script

Simplest approach - let Alfred trigger your existing fzf menu:

1. **Create workflow:** "Dev Launcher"
2. **Add Hotkey:** ⌘⇧D
3. **Add Script:**
   ```bash
   export PATH=/usr/local/bin:/opt/homebrew/bin:$PATH

   osascript <<EOF
   tell application "Terminal"
     activate
     do script "~/.local/bin/dev-launcher"
   end tell
   EOF
   ```

This just wraps your existing launcher - no changes needed!

## Benefits of Alfred Approach

✅ **Already approved:** Work-safe, you already use it
✅ **Professional:** Clean UI, built for productivity
✅ **Keyword access:** Type `dev` anywhere
✅ **Hotkey access:** ⌘⇧D still works
✅ **Visual editor:** Easy to modify workflows
✅ **Snippets:** Can add text expansion if needed
✅ **Clipboard:** Can integrate with clipboard history

## Cool Alfred Features You Can Add

### Quick VM Status Check

Add keyword `vm` that shows Parallels VM status:

```bash
prlctl list -a | grep -v "UUID"
```

### Quick SSH to Jump Box

Add keyword `work-jump`:

```bash
osascript -e 'tell application "Terminal"
  do script "ssh jumpbox.internal.company.com"
end tell'
```

### Environment Variable Lookup

Add keyword `env {query}`:

```bash
printenv {query}
```

## Export Workflows for Backup

Alfred workflows can be exported:

1. **Right-click workflow** → Export
2. **Save to:** `~/dotfiles/environment-launcher/alfred-workflows/`
3. **Commit to repo** (they're .alfredworkflow files)

## Recommendation

**Option 1:** Simple wrapper (triggers existing dev-launcher)
- Fastest to set up
- Uses your existing fzf menu
- No duplication of container definitions

**Option 2:** Native Alfred List Filter
- Prettier UI
- Better Alfred integration
- Need to maintain container list in two places

**I'd recommend Option 1** - let Alfred trigger your existing `dev-launcher` script.

## Integration with Work Laptop

Add to your `~/.zshrc.local`:

```bash
# Alfred is available for hotkeys
export DEV_LAUNCHER_TOOL="alfred"
```

This way your dotfiles can detect which tool is being used.
