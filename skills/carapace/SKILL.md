---
name: carapace
description: Carapace container environment for OpenClaw — X11 display, Nix packages, file serving, and browser automation.
---

# Carapace Environment

Carapace is a container environment for OpenClaw with persistent services, a virtual display, and on-demand package management.

## Why Carapace?

Carapace provides AI agents with GUI capabilities in an **isolated container** rather than direct access to a user's desktop. This approach:

- **Sandboxes risk** — Agent actions are contained; mistakes don't affect your main system
- **Enables GUI automation** — Browser, image editing, and visual tools without screen sharing
- **Preserves privacy** — Your personal desktop, files, and credentials stay separate
- **Simplifies setup** — Pre-configured environment with all dependencies included

Think of it as giving the agent its own workstation rather than remote access to yours.

## Services

| Service     | URL                     | Description                                  |
| ----------- | ----------------------- | -------------------------------------------- |
| Xpra        | `http://localhost:7756` | Web-accessible X11 display                   |
| File Server | `http://localhost:8080` | Static file serving from `/workspace/public` |

## X11 Display

A virtual X11 display is available via Xpra.

```bash
DISPLAY=:99
XAUTHORITY=/home/openclaw/.runtime/xpra/Xauthority-99
FONTCONFIG_FILE=/home/openclaw/.config/fontconfig/fonts.conf
```

These are set in the environment by default. GUI applications can be launched and viewed through the Xpra web interface.

## Nix Package Manager

Nix is available for on-demand package installation:

```bash
# Run a command with a package
nix-shell -p <package> --run "<command>"

# Example: run htop
nix-shell -p htop --run "htop"

# Example: use imagemagick
nix-shell -p imagemagick --run "convert input.png -resize 50% output.png"
```

Packages are cached after first use. Search available packages at [search.nixos.org](https://search.nixos.org/packages).

## Chromium Browser

A Chromium wrapper is available with container-friendly defaults:

```bash
chromium "<url>"
```

Located at `~/.local/bin/chromium`. Includes flags for:

- No sandbox (container environment)
- Software rendering (no GPU)
- Crash reporter disabled
- Fontconfig integration

## Public Files

Files placed in `/workspace/public` are served by ran-http on port 8080.

```bash
# Create a shareable file
echo "Hello" > /workspace/public/hello.txt

# Access locally
curl http://localhost:8080/hello.txt
```

The file server can be exposed publicly via reverse proxy (Traefik, Caddy, etc.) if desired.

## Directory Structure

```
/workspace/              # OpenClaw workspace root
├── public/              # Publicly served files
├── skills/              # Installed skills
├── memory/              # Daily memory files
└── ...

/home/openclaw/
├── .local/bin/          # User scripts (chromium wrapper)
├── .config/fontconfig/  # Font configuration
├── .runtime/xpra/       # Xpra runtime files
└── .nix-profile/        # Nix profile (installed packages)
```

## Tips

- **Screenshots**: Use `nix-shell -p scrot --run "scrot screenshot.png"` or xpra's built-in screenshot
- **PDF generation**: Chromium can print to PDF with `--print-to-pdf`
- **File transfers**: If Tailscale is configured, use `tailscale file cp <file> <device>:`
- **Fonts**: Additional fonts can be installed via Nix and added to fontconfig
