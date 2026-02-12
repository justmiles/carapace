# Carapace

Carapace is a robust container environment designed for **OpenClaw**, providing an isolated workspace with GUI capabilities, persistent services, and on-demand package management. It enables AI agents to perform tasks requiring a desktop interface (like web browsing) securely within a container.

## Features

- **Isolated Workspace**: Runs in a Docker container, keeping agent actions sandboxed from the host system.
- **GUI Capabilities**: Includes a virtual X11 display accessible via web browser using **Xpra**.
- **Browser Automation**: Pre-configured **Chromium** wrapper optimized for container environments.
- **Package Management**: Integrated **Nix** package manager for installing tools on the fly.
- **File Serving**: Static file server (**ran-http**) exposing `/workspace/public`.
- **Service Management**: Uses **s6-overlay** for reliable process supervision.
- **Networking**: **Tailscale** integration for secure remote access.

## Services & Ports

| Service | Port | Description |
|---------|------|-------------|
| **Xpra** | `7756` | Web-accessible X11 display. Access at `http://localhost:7756`. |
| **File Server** | `8080` | Serves files from `/workspace/public`. |
| **OpenClaw** | `18789` | The OpenClaw agent service. |

## Getting Started

### Prerequisites

- Docker or Podman

### Building the Image

```bash
docker build -t justmiles/carapace .
```

### Running the Container

```bash
docker run -d \
  -p 7756:7756 \
  -p 8080:8080 \
  -p 18789:18789 \
  --name carapace-instance \
  justmiles/carapace
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

- `/workspace/` - Root workspace for OpenClaw.
  - `public/` - Files served via HTTP.
  - `skills/` - Installed skills (includes the `carapace` skill itself).
- `/home/openclaw/` - User home directory.
  - `.local/bin/` - Custom scripts.
  - `.nix-profile/` - Nix packages.

## Development

This project includes a `devbox.json` file for reproducible development environments.

```bash
devbox shell
```
