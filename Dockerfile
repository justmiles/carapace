FROM node:22-bookworm AS openclaw-builder

# Install Bun (required for build scripts)
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

RUN corepack enable

WORKDIR /app

# Install git and other potential dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV GITHUB_RELEASE_OPENCLAW__OPENCLAW=2026.2.13 \
    OPENCLAW_PREFER_PNPM=1

# Install OpenClaw
RUN git clone https://github.com/openclaw/openclaw.git -b ${GITHUB_RELEASE_OPENCLAW__OPENCLAW} . \
    && pnpm install --frozen-lockfile \
    && (cd extensions/diagnostics-otel && pnpm install) \
    && OPENCLAW_A2UI_SKIP_MISSING=1 pnpm build \
    && pnpm ui:build \
    && CI=true pnpm prune --prod

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

# Install packages needed for Carapace
RUN export PATH=$HOME/.nix-profile/bin:$PATH \
  && NIXPKGS_ALLOW_UNFREE=1 nix-env -iA \
  nixpkgs.adwaita-icon-theme \
  nixpkgs.chromium \
  nixpkgs.code-server \
  nixpkgs.curl \
  nixpkgs.dejavu_fonts \
  nixpkgs.devbox \
  nixpkgs.fontconfig \
  nixpkgs.gobject-introspection \
  nixpkgs.jq \
  nixpkgs.liberation_ttf \
  nixpkgs.menu-cache \
  nixpkgs.nodejs_22 \
  nixpkgs.noto-fonts \
  nixpkgs.pipx \
  nixpkgs.pwgen \
  nixpkgs.python3 \
  nixpkgs.python311Packages.pip \
  nixpkgs.python3Packages.pygobject3 \
  nixpkgs.python3Packages.pyxdg \
  nixpkgs.python3Packages.gst-python \
  nixpkgs.ran \
  nixpkgs.rsync \
  nixpkgs.shared-mime-info \
  nixpkgs.unzip \
  nixpkgs.xdg-utils \
  nixpkgs.xhost \
  nixpkgs.xpra \
  nixpkgs.yq \
 && nix-env --delete-generations old \
 && nix-store --gc

# Install packages my OpenClaw instance constantly asks for
RUN export PATH=$HOME/.nix-profile/bin:$PATH \
  && NIXPKGS_ALLOW_UNFREE=1 nix-env -iA \
  nixpkgs.git \
  nixpkgs.curl \
  nixpkgs.wget \
  nixpkgs.jq \
  nixpkgs.htop \
  nixpkgs.tree \
  nixpkgs.tmux \
  nixpkgs.nano \
  nixpkgs.imagemagick \
  nixpkgs.ffmpeg \
  nixpkgs.nmap \
  nixpkgs.zip \
  nixpkgs.unzip \
  nixpkgs.p7zip \
  nixpkgs.ripgrep \
  nixpkgs.fd \
  nixpkgs.tea \
  nixpkgs.nomad \
  nixpkgs.scrot \
  nixpkgs.poppler-utils \
  nixpkgs.chezmoi \
 && nix-env --delete-generations old \
 && nix-store --gc

COPY --chown=openclaw:openclaw .local/bin /home/openclaw/.local/bin

USER root

# Copy OpenClaw
COPY --from=openclaw-builder --chown=openclaw:openclaw /app /home/openclaw/app
COPY --chown=openclaw:openclaw skills/carapace /home/openclaw/app/skills/carapace

# Copy custom 404 page
COPY --chown=openclaw:openclaw public/404.html /usr/share/openclaw/404.html

# Copy s6-overlay configs
COPY s6-overlay /etc/s6-overlay

RUN mkdir -p /workspace /var/log

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

# Expose ports for ran-http (8080), openclaw (18789), and xpra (7756)
EXPOSE 8080 18789 7756

ENTRYPOINT ["/init"]

CMD ["/usr/bin/sleep", "infinity"]
