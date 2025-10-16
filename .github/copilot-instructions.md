
# Copilot Instructions for AI Coding Agents

This repository manages modular Nix/NixOS configurations for multiple systems. Key guidelines for AI agents:

## Architecture & Organization
- Modular structure:
  - `modules/` (apps, cli, desktops, sys, hw)
  - `suites/` (collections for use cases)
  - `hosts/` (host configs: qbert, donkeykong, srv)
  - `archetype/` (system roles)
  - `lib/` (autoimport, browser wrappers, desktop file creation)
  - `docs/`, `settings/`, `secrets/`
- Auto-import: `lib/autoimport.nix` recursively imports `.nix` files, excluding certain dirs (see `CLAUDE.md`).
- Feature flags: Conditional build via `~/.config/nix-flags/`.

## Developer Workflows
- Use `just` for all dev tasks:
  - `just check` (syntax validation)
  - `just test` (dry-build)
  - `just rebuild` (system rebuild)
  - `just rebuild trace=true` (trace output)
- NEVER run rebuild/tests unless explicitly instructed.
- Bootstrap: Deploy via shell script (`curl ... | sudo nix-shell shell.nix`).

## Patterns & Integration
- Desktop apps: Use `lib/cbb-webwrap/makeDesktopApp` (see `lib/cbb-webwrap/README.md`).
- Module toggling: `enable = true/false;` in host configs.
- Secrets/settings: Use `settings/settings.json`, `secrets/secrets.json`.
- No user-specific hardcoding in reusable flakes (see `_hyprflake/CLAUDE.md`).
- External APIs: Some modules (e.g., `zed-ai`, see `modules/cli/zed-ai/README.md`) require secrets/env vars.
- Home Manager & Stylix: Core dependencies for user config/theming.
- Nixpkgs & Hyprland: Standard package/window manager integration.

## File & Test Conventions
- End files with a blank line.
- Favor small, pure, immutable functions.
- Avoid shortcuts/hacks; prefer maintainability.
- Use real schemas/types in tests; never redefine.
- Never mock in tests.

## References
- See `CLAUDE.md`, `_hyprflake/CLAUDE.md` for architecture and design.
- See `docs/README.md`, `README.md` for quickstart and system overview.
- See module READMEs (e.g., `lib/cbb-webwrap/README.md`, `modules/cli/zed-ai/README.md`) for usage examples.

---

**If any section is unclear or missing, provide feedback so instructions can be improved.**
