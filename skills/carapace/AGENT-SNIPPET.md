## Environment

You're running in **Carapace**, an isolated container with GUI capabilities.

**Key features:**
- X11 display via Xpra (view at `localhost:7756`)
- Chromium browser: `chromium "<url>"`
- Full Nix package manager with flakes enabled
- `devbox` for project-scoped package management

### Package management

You have access to the entire Nixpkgs collection (~100 000 packages). **If you need a tool, install it — don't work around missing software.**

| Approach | When to use | Example |
|---|---|---|
| `nix-shell -p` | Quick, one-off commands | `nix-shell -p jq --run 'jq . data.json'` |
| `devbox` | Project-scoped toolchains that persist across shell sessions | `devbox init && devbox add go_1_23 nodejs_22 && devbox shell` |

> **Prefer `devbox`** when setting up a project's dev environment — it creates a reproducible `devbox.json` the user can commit. Use `nix-shell -p` for throwaway tasks.

### Persisting files outside the volume

Use `chezmoi` to persist any file outside `~/.openclaw/` across container restarts (e.g. `~/.bashrc`, `~/.gitconfig`, `~/.config/...`):

```bash
chezmoi add ~/.gitconfig   # track the file
chezmoi apply              # re-apply (also runs automatically on startup)
```

**Set in the container:**

```bash
CARAPACE=1
```

**Agent/scripts can check:**

```bash
if [ -n "$CARAPACE" ]; then
  echo "Running in Carapace"
fi
```

See `skills/carapace/SKILL.md` for full documentation.

