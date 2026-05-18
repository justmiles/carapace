{
  description = "Carapace — package environment for the OpenClaw container";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    claude-code.url = "github:sadjow/claude-code-nix";
  };

  outputs = { self, nixpkgs, claude-code }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (final: prev: {
            # Skip Nomad's Go test suite — it exhausts disk space in Docker builds
            nomad = prev.nomad.overrideAttrs (old: { doCheck = false; });
          })
        ];
      };
    in {
      packages.${system} = rec {

        # Core packages required by Carapace itself (GUI, runtime, dev tools)
        carapace-core = pkgs.buildEnv {
          name = "carapace-core";
          paths = [
            # --- Display & fonts ---
            pkgs.adwaita-icon-theme
            pkgs.dejavu_fonts
            pkgs.fontconfig
            pkgs.liberation_ttf
            pkgs.noto-fonts
            pkgs.xdg-utils
            pkgs.xhost

            # --- Remote display (noVNC + x11vnc) ---
            pkgs.x11vnc
            pkgs.novnc
            pkgs.python3Packages.websockify
            pkgs.xorg.xorgserver   # Xvfb

            # --- X11 keyboard support ---
            pkgs.xkeyboard_config
            pkgs.xorg.setxkbmap
            pkgs.xorg.xkbcomp

            # --- Browser ---
            pkgs.chromium

            # --- IDE / code-server ---
            pkgs.code-server

            # --- Package management ---
            pkgs.devbox
            pkgs.pipx

            # --- Python ---
            pkgs.python3
            pkgs.python3Packages.pip
            pkgs.python3Packages.pyxdg

            # --- Desktop integration ---
            pkgs.shared-mime-info

            # --- Node.js runtime ---
            pkgs.nodejs_22

            # --- Basic CLI utilities ---
            pkgs.curl
            pkgs.jq
            pkgs.pwgen
            pkgs.rsync
            pkgs.unzip
            pkgs.yq
          ];
        };

        # Packages the OpenClaw agent commonly reaches for (nice-to-have, not required by Carapace itself)
        carapace-agent = pkgs.buildEnv {
          name = "carapace-agent";
          paths = [
            # --- Version control & networking ---
            pkgs.git
            pkgs.wget
            pkgs.nmap

            # --- Data & text processing ---
            pkgs.ripgrep
            pkgs.fd
            pkgs.poppler-utils   # PDF tools

            # --- Archive tools ---
            pkgs.zip
            pkgs.p7zip

            # --- Media processing ---
            pkgs.imagemagick
            pkgs.ffmpeg
            pkgs.scrot           # Screenshots

            # --- Shell & system utilities ---
            pkgs.htop
            pkgs.tree
            pkgs.tmux
            pkgs.nano

            # --- Infrastructure & deployment ---
            pkgs.nomad
            pkgs.tea             # Gitea CLI
            pkgs.chezmoi         # Dotfiles management

            # --- AI coding assistants ---
            claude-code.packages.${system}.claude-code
          ];
        };

        # Combined environment — what gets installed in the container
        default = pkgs.buildEnv {
          name = "carapace";
          paths = [ carapace-core carapace-agent ];
          ignoreCollisions = true;
        };

      };
    };
}
