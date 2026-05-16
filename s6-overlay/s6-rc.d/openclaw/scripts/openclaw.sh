#!/command/with-contenv bash

export HOME=/home/openclaw
export PATH=$PATH:/home/openclaw/.local/bin:/home/openclaw/.nix-profile/bin

cd /home/openclaw/app/node_modules/openclaw

# Resolve the workspace path from config, falling back to the OpenClaw default
OPENCLAW_WORKSPACE="$(jq -r '.agents.defaults.workspace // empty' /home/openclaw/.openclaw/openclaw.json 2>/dev/null)"
OPENCLAW_WORKSPACE="${OPENCLAW_WORKSPACE:-/home/openclaw/.openclaw/workspace}"

# if carapace skill is not installed, install it
if [ ! -d "$OPENCLAW_WORKSPACE/skills/carapace" ]; then
    mkdir -p "$OPENCLAW_WORKSPACE/skills"
    rsync -avz --exclude "AGENT-SNIPPET.md" /home/openclaw/app/skills/carapace/ "$OPENCLAW_WORKSPACE/skills/carapace/"
fi

# if AGENTS snippet not in AGENTS.md, install it
if [ ! -f "$OPENCLAW_WORKSPACE/AGENTS.md" ] || ! grep -q "Carapace" "$OPENCLAW_WORKSPACE/AGENTS.md"; then
    echo "" >> "$OPENCLAW_WORKSPACE/AGENTS.md"
    cat /home/openclaw/app/skills/carapace/AGENT-SNIPPET.md >> "$OPENCLAW_WORKSPACE/AGENTS.md"
fi

# Install OpenClaw OS plugin
node dist/index.js plugins install -l /home/openclaw/app/node_modules/@openuidev/openclaw-os-plugin --force 2>&1 || echo "Warning: Failed to install OpenClaw OS plugin"

node dist/index.js gateway --allow-unconfigured
