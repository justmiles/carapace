#!/command/with-contenv bash
set -e

CHEZMOI_SOURCE="/home/openclaw/.local/share/chezmoi"

# Only run if the chezmoi source directory exists and is non-empty
if [ -d "$CHEZMOI_SOURCE" ] && [ "$(ls -A "$CHEZMOI_SOURCE" 2>/dev/null)" ]; then
    echo "Applying chezmoi files..."
    s6-setuidgid openclaw /home/openclaw/.nix-profile/bin/chezmoi apply --force 2>&1
    echo "chezmoi apply complete."
else
    echo "No chezmoi source directory found — skipping."
fi
