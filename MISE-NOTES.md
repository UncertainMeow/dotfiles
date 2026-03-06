# Mise Quick Reference

Mise (pronounced "meez") replaces nvm, pyenv, rbenv, and asdf with one tool.
Your `.zshrc` already activates it — just start using it.

## Install a runtime

```bash
mise use node@22          # Install Node 22 and set it as default in this project
mise use python@3.12      # Same for Python
mise use go@latest        # Latest Go
```

This creates a `.mise.toml` in your current directory (project-scoped).

## Global defaults

```bash
mise use -g node@22       # Set Node 22 as your system-wide default
mise use -g python@3.12   # Same for Python globally
```

Global config lives at `~/.config/mise/config.toml`.

## See what's installed

```bash
mise ls                   # Everything installed
mise ls node              # Just Node versions
mise current              # What's active right now
```

## Common workflows

```bash
# Start a new Node project
mkdir my-project && cd my-project
mise use node@22
node --version            # Confirms 22.x

# Pin a specific version for a project
mise use node@20.11.0     # Exact version in .mise.toml

# See what mise would activate for this directory
mise doctor               # Health check + diagnostics

# Update all installed tools
mise upgrade
```

## How it works

- `mise use` in a directory creates `.mise.toml` (commit this to git)
- When you `cd` into that directory, mise automatically switches versions
- No shims — mise modifies your PATH directly (faster than asdf)
- Works with any tool that has an asdf plugin or a mise backend

## Docs

- https://mise.jdx.dev/getting-started.html
- `mise help` for CLI reference
