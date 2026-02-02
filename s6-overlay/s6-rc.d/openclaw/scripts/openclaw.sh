#!/command/with-contenv bash

export HOME=/home/openclaw
export PATH=$PATH:/home/openclaw/.local/bin:/home/openclaw/.nix-profile/bin

cd /home/openclaw/app

OPENCLAW_WORKSPACE="$(jq -r '.agents.defaults.workspace' /home/openclaw/.openclaw/openclaw.json)"
OPENCLAW_WORKSPACE="${OPENCLAW_WORKSPACE:-/workspace}"

# if carapace skill is not installed, install it
if [ ! -d "$OPENCLAW_WORKSPACE/skills/carapace" ]; then
    mkdir -p "$OPENCLAW_WORKSPACE/skills"
    rsync -avz --exclude "AGENT-SNIPPET.md" /home/openclaw/app/skills/carapace/ "$OPENCLAW_WORKSPACE/skills/carapace/"
fi

# if AGENTS snippet not in ~/.local/share/openclaw/AGENTS.md, install it
if ! grep -q "Carapace" "$OPENCLAW_WORKSPACE/AGENTS.md"; then
    echo "" >> "$OPENCLAW_WORKSPACE/AGENTS.md"
    cat /home/openclaw/app/skills/carapace/AGENT-SNIPPET.md >> "$OPENCLAW_WORKSPACE/AGENTS.md"
fi

node dist/index.js gateway --allow-unconfigured
