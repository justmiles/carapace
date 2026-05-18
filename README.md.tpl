# Carapace

Carapace is a robust container environment designed for **OpenClaw**, providing an isolated workspace with GUI capabilities, persistent services, and on-demand package management. It enables AI agents to perform tasks requiring a desktop interface (like web browsing) securely within a container.

[![Build Status](https://drone.justmiles.io/api/badges/justmiles/carapace/status.svg)](https://drone.justmiles.io/justmiles/carapace)

## Features

- **Isolated Workspace**: Runs in a Docker container, keeping agent actions sandboxed from the host system.
- **GUI Capabilities**: Includes a virtual X11 display accessible via web browser using **noVNC** + **x11vnc**.
- **Browser Automation**: Pre-configured **Chromium** wrapper optimized for container environments.
- **Package Management**: Integrated **Nix** package manager for installing tools on the fly.
- **Service Management**: Uses **s6-overlay** for reliable process supervision.
- **Networking**: **Tailscale** integration for secure remote access.

## Services & Ports

| Service | Port | Description |
|---------|------|-------------|
| **noVNC** | `6080` | Web-accessible X11 display (VNC over WebSocket). Access at `http://localhost:6080/vnc.html`. |
| **OpenClaw** | `18789` | The OpenClaw agent service. |

## Getting Started

### Prerequisites

- Docker or Podman

### Building the Image

```bash
docker build -t justmiles/carapace:{{TAG}} .
```

### Running the Container

```bash
docker run -d \
  -p 6080:6080 \
  -p 18789:18789 \
  --name carapace-instance \
  justmiles/carapace:{{TAG}}
```

### Recommended Run Configuration

To run Carapace with full capabilities, including Tailscale integration and persistent storage, use the following configuration:

1.  **Generate an OpenClaw Gateway Token:**
    ```bash
    openssl rand -hex 32
    ```
2.  **Obtain a Tailscale Auth Key:**
    Generate a new auth key from your [Tailscale Admin Console](https://login.tailscale.com/admin/settings/keys).

3.  **Run the Container:**
    Replace `<YOUR_TAILSCALE_AUTH_KEY>` and `<YOUR_GENERATED_TOKEN>` with your values.

    ```bash
    docker run -it --rm --name carapace \
      -e TS_AUTH_KEY="<YOUR_TAILSCALE_AUTH_KEY>" \
      -e TS_HOSTNAME="openclaw-dev" \
      -e TS_STATE_DIR="/home/openclaw/.openclaw/.tailscale" \
      -e TS_ACCEPT_ROUTES="true" \
      -e TS_USERSPACE="true" \
      -e TS_ACCEPT_DNS="true" \
      -e TS_EXTRA_ARGS="--ssh" \
      -e OPENCLAW_GATEWAY_TOKEN="<YOUR_GENERATED_TOKEN>" \
      -v $PWD/.data/openclaw:/home/openclaw/.openclaw \
      justmiles/carapace:{{TAG}}
    ```

### First-Time Setup

If this is your first time using OpenClaw, open a shell in the running container and complete the onboarding process:

```bash
docker exec -it carapace bash
openclaw onboard
```

## Environment Details

### Nix Package Manager

Carapace uses Nix to allow the agent to install tools without root privileges.

```bash
# Example: Install and run htop
nix-shell -p htop --run "htop"
```

### Chromium Wrapper

A custom wrapper for Chromium is provided at `~/.local/bin/chromium` to ensure it runs smoothly in the container (disables GPU, sandbox, etc.).

```bash
chromium "https://example.com"
```

### Directory Structure

- `/home/openclaw/.openclaw/` - Persistent state (single volume mount).
  - `workspace/` - Default workspace for OpenClaw.
    - `skills/` - Installed skills (includes the `carapace` skill itself).
  - `chezmoi/` - Chezmoi source directory (persisted dotfiles).
  - `openclaw.json` - OpenClaw configuration.
- `/home/openclaw/` - User home directory.
  - `.local/bin/` - Custom scripts.
  - `.local/share/chezmoi/` - Symlink to `.openclaw/chezmoi`.
  - `.nix-profile/` - Nix packages.

### Chezmoi (Dotfile Persistence)

Carapace uses [chezmoi](https://www.chezmoi.io/) to persist files **outside** the persistent volume. The chezmoi source directory is symlinked into the persistent volume, and `chezmoi apply` runs automatically on every container startup.

This allows the agent to manage dotfiles and configuration (e.g. `~/.bashrc`, `~/.gitconfig`) that are restored to their correct filesystem locations after each restart.

## Development

This project includes a `devbox.json` file for reproducible development environments.

```bash
devbox shell
```

