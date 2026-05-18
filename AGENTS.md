# Agent Instructions for Carapace

## README

`README.md` is **generated** from `README.md.tpl`. Do not edit `README.md` directly — all changes must be made to `README.md.tpl`.

## Directory Strategy

The only persistent volume is `/home/openclaw/.openclaw`. The workspace lives at `~/.openclaw/workspace` (the OpenClaw default). Do not create or reference a top-level `/workspace` directory.

## Persisting Files with Chezmoi

The container uses [chezmoi](https://www.chezmoi.io/) to persist files **outside** the persistent volume across container restarts. The chezmoi source directory (`~/.local/share/chezmoi`) is symlinked into the persistent volume at `~/.openclaw/chezmoi`, and `chezmoi apply` runs automatically on every container startup.

Use this when you need to persist configuration files, dotfiles, or any other files that live outside `~/.openclaw/` (e.g. `~/.bashrc`, `~/.gitconfig`, `~/.config/...`).

```bash
# Add a file to chezmoi management
chezmoi add ~/.bashrc

# Edit a managed file
chezmoi edit ~/.bashrc

# Apply all managed files (also runs automatically on startup)
chezmoi apply
```

Any files added to chezmoi will be restored to their correct filesystem locations on the next container startup, even though only `~/.openclaw/` is a persistent volume.
