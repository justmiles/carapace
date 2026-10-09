# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Changed

- Bump bundled OpenClaw from `v2026.2.23` to `v2026.9.9` via automated Renovate updates.
- Migrate Renovate configuration to the new config format.

### Fixed

- Fix extra space in `PATH` assignment in the `update-user` startup script.

## [v0.0.4] - 2026-02-24

### Added

- Tag the OpenClaw build with its semantic version (`V` build arg) so images can be traced back to the bundled OpenClaw release.

### Changed

- Bump bundled OpenClaw from `v2026.2.17` to `v2026.2.22` via automated Renovate updates.

## [v0.0.3] - 2026-02-13

### Fixed

- Allow read/write access to the Xpra directory and fix an incorrect path.

## [v0.0.2] - 2026-02-13

### Added

- Introduce `README.md.tpl` for generating `README.md` with the current image tag.
- Manage the bundled OpenClaw version via Renovate.

### Changed

- Improve Drone CI pipeline and Docker tagging strategy.
- Reduce the number of Dockerfile layers.
- Limit Renovate to the regex manager and enable automerge.
- Remove Docker BuildKit usage.
- Update README with running instructions and add `.envrc` to `.gitignore`.

### Fixed

- Fix ownership (`chown`) of the OpenClaw user's files.

## [v0.0.1] - 2026-02-12

### Added

- Initial release of Carapace: a containerized, OpenClaw-ready workspace with:
  - Xpra-based web-accessible X11 display.
  - Chromium wrapper tuned for containerized environments.
  - Nix package manager for on-demand tool installation.
  - Static file server (`ran-http`) for `/workspace/public`.
  - s6-overlay service supervision.
  - Tailscale integration for secure remote access.
- Documentation and package list in the README.

[Unreleased]: https://github.com/justmiles/carapace/compare/v0.0.4...HEAD
[v0.0.4]: https://github.com/justmiles/carapace/compare/v0.0.3...v0.0.4
[v0.0.3]: https://github.com/justmiles/carapace/compare/v0.0.2...v0.0.3
[v0.0.2]: https://github.com/justmiles/carapace/compare/v0.0.1...v0.0.2
[v0.0.1]: https://github.com/justmiles/carapace/releases/tag/v0.0.1
