#!/command/with-contenv bash
set -e

# Set openclaw UID/GID
[ ! -z "${OPENCLAW_UID}" ] && usermod -u $OPENCLAW_UID openclaw > /dev/null
[ ! -z "${OPENCLAW_GID}" ] && groupmod -g $OPENCLAW_GID openclaw > /dev/null

# if not in `~/.bashrc`, add PATH
OPENCLAW_PATH="/home/openclaw/bin:/home/openclaw/.local/bin:/home/openclaw/.nix-profile/bin"
if ! grep -q "$OPENCLAW_PATH" "/home/openclaw/.bashrc"; then
    echo "export PATH=$PATH:$OPENCLAW_PATH" >> /home/openclaw/.bashrc
fi

# Persist chezmoi source directory inside the persistent volume
mkdir -p /home/openclaw/.openclaw/chezmoi
mkdir -p /home/openclaw/.local/share
ln -sfn /home/openclaw/.openclaw/chezmoi /home/openclaw/.local/share/chezmoi

chown -R openclaw:openclaw /home/openclaw/.openclaw
