FROM ubuntu:noble

RUN userdel -r ubuntu && useradd --create-home --shell /bin/bash openclaw

ENV DEBIAN_FRONTEND=noninteractive

# Install basic Apt Packages
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    less \
    lsof \
    iputils-ping \
    gnupg \
    xz-utils \
    ca-certificates \
    dbus \
    lib32gcc-s1 lib32stdc++6 lib32z1 \
  && apt-get clean autoclean \
  && apt-get autoremove --yes \
  && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
  && mkdir -p /var/lib/dbus \
  && dbus-uuidgen > /var/lib/dbus/machine-id \
  && ln -sf /var/lib/dbus/machine-id /etc/machine-id

# Install s6-overlay
ENV S6_OVERLAY_VERSION="3.2.1.0"
RUN curl -sfLo - https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz | tar -Jxpf - -C /
RUN curl -sfLo - https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz | tar -Jxpf - -C /

# Install tailscale
RUN curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.gpg | apt-key add - \
     && curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.list | tee /etc/apt/sources.list.d/tailscale.list \
     && apt-get update \
     && apt-get install -y tailscale

# Install Node.js 22 (required to run OpenClaw)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
  && apt-get install -y nodejs \
  && corepack enable

# Install Nix
RUN curl -fsSL https://nixos.org/nix/install -o /tmp/nix-install \
    && chmod 666 /tmp/nix-install \
    && groupadd nixbld \
    && usermod -a -G nixbld openclaw \
    && mkdir -m 0755 /nix && chown -R openclaw /nix

# Cleanup
RUN find /var/log -type f | xargs -I % truncate -s0 %

USER openclaw

RUN sh /tmp/nix-install --no-daemon

WORKDIR /home/openclaw

# Enable Nix flakes
RUN mkdir -p /home/openclaw/.config/nix \
  && echo 'experimental-features = nix-command flakes' > /home/openclaw/.config/nix/nix.conf

# Install packages from flake
COPY --chown=openclaw:openclaw flake.nix flake.lock /home/openclaw/
RUN export PATH=$HOME/.nix-profile/bin:$PATH \
  && cd /home/openclaw \
  && nix profile install .#default --print-build-logs --show-trace \
  && nix-collect-garbage -d

# Install OpenClaw and plugins from npm (pre-built, no compilation needed)
ENV NPM_PACKAGE_OPENCLAW=2026.5.12 \
    NPM_PACKAGE_OPENUIDEV__OPENCLAW_OS_PLUGIN=0.1.5

RUN npm install --prefix /home/openclaw/app \
  openclaw@${NPM_PACKAGE_OPENCLAW} \
  @openuidev/openclaw-os-plugin@${NPM_PACKAGE_OPENUIDEV__OPENCLAW_OS_PLUGIN}

COPY --chown=openclaw:openclaw .local/bin /home/openclaw/.local/bin

USER root

# Copy Carapace skill
COPY --chown=openclaw:openclaw skills/carapace /home/openclaw/app/skills/carapace


# Copy s6-overlay configs
COPY s6-overlay /etc/s6-overlay

RUN mkdir -p /var/log

# S6 settings
ENV S6_VERBOSITY=1 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2

# X11 settings
ENV DISPLAY=:99 \
    FONTCONFIG_FILE=/home/openclaw/.config/fontconfig/fonts.conf \
    XAUTHORITY=/home/openclaw/.runtime/xpra/Xauthority-99

# Container settings
ENV PATH=$PATH:/home/openclaw/bin:/home/openclaw/.nix-profile/bin \
CARAPACE=1

# Expose ports for openclaw (18789) and xpra (7756)
EXPOSE 18789 7756

ENTRYPOINT ["/init"]

CMD ["/usr/bin/sleep", "infinity"]
