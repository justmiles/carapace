#!/command/with-contenv bash
set -e

# Set openclaw UID/GID
[ ! -z "${OPENCLAW_UID}" ] && usermod -u $OPENCLAW_UID openclaw > /dev/null
[ ! -z "${OPENCLAW_GID}" ] && groupmod -g $OPENCLAW_GID openclaw > /dev/null

# if not in `~/.bashrc`, add PATH
if ! grep -q "/home/openclaw/bin:/home/openclaw/.nix-profile/bin" "/home/openclaw/.bashrc"; then
    echo 'export PATH=$PATH:/home/openclaw/bin:/home/openclaw/.nix-profile/bin' >> /home/openclaw/.bashrc
fi

chown -R openclaw:openclaw /workspace
chown openclaw:openclaw /home/openclaw/.openclaw
