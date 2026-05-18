#!/command/with-contenv bash

cd /home/openclaw

export HOME=/home/openclaw
export XDG_DATA_DIRS=/usr/share:/home/openclaw/.nix-profile/share:/home/openclaw/.local/share
export XDG_RUNTIME_DIR=/home/openclaw/.runtime
export XDG_CONFIG_HOME=/home/openclaw/.config
export XDG_CACHE_HOME=/home/openclaw/.cache
export FONTCONFIG_FILE=/home/openclaw/.config/fontconfig/fonts.conf
export FONTCONFIG_PATH=/home/openclaw/.config/fontconfig
export XDG_MENU_PREFIX=ignore-

# Ensure machine-id exists for dconf
if [ ! -f /etc/machine-id ]; then
    if [ -f /var/lib/dbus/machine-id ]; then
        ln -s /var/lib/dbus/machine-id /etc/machine-id
    fi
fi

mkdir -p $XDG_RUNTIME_DIR $XDG_CONFIG_HOME $XDG_CACHE_HOME $FONTCONFIG_PATH $HOME/.local/share/applications
chmod 700 $XDG_RUNTIME_DIR

# Create Chromium desktop entry
cat <<EOF > $HOME/.local/share/applications/chromium.desktop
[Desktop Entry]
Version=1.0
Name=Chromium
GenericName=Web Browser
Comment=Access the Internet
Exec=/home/openclaw/.local/bin/chromium %U
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=chromium
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml_xml;application/x-mimearchive;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
EOF

cat <<EOF > $FONTCONFIG_FILE
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <dir>/home/openclaw/.nix-profile/share/fonts</dir>
  <cachedir>$XDG_CACHE_HOME/fontconfig-cache</cachedir>
</fontconfig>
EOF

export PATH=$PATH:/home/openclaw/bin:/home/openclaw/.nix-profile/bin

# XKB keyboard data
export XKB_CONFIG_ROOT=/home/openclaw/.nix-profile/share/X11/xkb
export XKB_DEFAULT_RULES=evdev
export XKB_DEFAULT_MODEL=pc105
export XKB_DEFAULT_LAYOUT=us

# Symlink XKB data to the standard system path if it doesn't exist
if [ ! -d /usr/share/X11/xkb ] && [ -d "$XKB_CONFIG_ROOT" ]; then
    mkdir -p /usr/share/X11 2>/dev/null || true
    ln -sf "$XKB_CONFIG_ROOT" /usr/share/X11/xkb 2>/dev/null || true
fi

# --- Display configuration ---
DISPLAY_NUM=99
SCREEN_RESOLUTION=1920x1080x24
VNC_PORT=5900
NOVNC_PORT=6080
NOVNC_WEB=/home/openclaw/.nix-profile/share/webapps/novnc

export DISPLAY=:${DISPLAY_NUM}

echo "Starting Xvfb on :${DISPLAY_NUM}..."
Xvfb :${DISPLAY_NUM} -screen 0 ${SCREEN_RESOLUTION} -ac +extension GLX +render -noreset &
XVFB_PID=$!

# Wait for Xvfb to be ready
for i in $(seq 1 30); do
    if [ -e "/tmp/.X11-unix/X${DISPLAY_NUM}" ]; then
        echo "Xvfb is ready"
        break
    fi
    sleep 0.2
done

# Allow local connections
xhost + 2>/dev/null || true

echo "Starting x11vnc on port ${VNC_PORT}..."
x11vnc \
    -display :${DISPLAY_NUM} \
    -rfbport ${VNC_PORT} \
    -nopw \
    -forever \
    -shared \
    -noxdamage \
    -xkb \
    -norc \
    -listen localhost \
    &
X11VNC_PID=$!

# Wait for x11vnc to be ready
sleep 1

echo "Starting noVNC/websockify on port ${NOVNC_PORT}..."
exec websockify \
    --web "${NOVNC_WEB}" \
    ${NOVNC_PORT} \
    localhost:${VNC_PORT}
