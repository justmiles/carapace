#!/command/with-contenv bash

cd /home/openclaw

export HOME=/home/openclaw
export XDG_DATA_DIRS=/usr/share:/home/openclaw/.nix-profile/share:/home/openclaw/.local/share
export XDG_RUNTIME_DIR=/home/openclaw/.runtime
export XDG_CONFIG_HOME=/home/openclaw/.config
export XDG_CACHE_HOME=/home/openclaw/.cache
export FONTCONFIG_FILE=/home/openclaw/.config/fontconfig/fonts.conf
export FONTCONFIG_PATH=/home/openclaw/.config/fontconfig
export GI_TYPELIB_PATH=/home/openclaw/.nix-profile/lib/girepository-1.0
export PYTHONPATH=/home/openclaw/.nix-profile/lib/python3.13/site-packages:$PYTHONPATH
export XDG_MENU_PREFIX=ignore-

# Ensure machine-id exists for dconf
if [ ! -f /etc/machine-id ]; then
    if [ -f /var/lib/dbus/machine-id ]; then
        ln -s /var/lib/dbus/machine-id /etc/machine-id
    fi
fi

mkdir -p $XDG_RUNTIME_DIR $XDG_CONFIG_HOME/menus $XDG_CACHE_HOME $FONTCONFIG_PATH $HOME/.local/share/applications

# Create applications.menu to fix "File not found" error
cat <<EOF > $XDG_CONFIG_HOME/menus/applications.menu
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
 "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">
<Menu>
  <Name>Applications</Name>
  <DefaultAppDirs/>
  <DefaultDirectoryDirs/>
  <Include>
    <Filename>chromium.desktop</Filename>
  </Include>
  <Layout>
    <Filename>chromium.desktop</Filename>
    <Merge type="menus"/>
    <Merge type="files"/>
  </Layout>
</Menu>
EOF

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

xpra start :99 \
    --bind-tcp=0.0.0.0:7756 \
    --tcp-auth=none \
    --no-daemon \
    --mdns=no \
    --webcam=no \
    --pulseaudio=no \
    --printing=no \
    --notifications=no \
    --dbus-launch=no \
    --bell=no \
    --opengl=no \
    --lock=no \
    --sharing=yes \
    --readonly=no \
    --clipboard=yes \
    --file-transfer=yes \
    --resize-display=yes \
    --forward-xdg-open=no \
    --start "xhost +"
