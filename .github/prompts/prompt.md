---
mode: ask
---

# NixOS Configuration Repository

This is a comprehensive NixOS configuration repository managing multiple systems (donkey-kong, qbert, srv) with a modular, declarative approach using Nix flakes.

## Repository Overview

- **Purpose**: Manage Dustin Krysak's NixOS systems with a declarative approach
- **Systems**: Multiple hosts (workstations: donkey-kong, qbert; server: srv)
- **Architecture**: Modular design with auto-import system and clear organization

## Architecture

### Flake Structure

- **Inputs**: Multiple channels (stable 25.05, unstable), home-manager, hardware configs, specialized tools
- **Systems**: Three main configurations (donkey-kong/qbert as workstations, srv as server)
- **Overlays**: Unstable packages available under `pkgs.unstable`
- **specialArgs**: User settings, secrets, and isWorkstation flag passed to all modules

### Module System

The repository uses an **auto-import** system (`autoimport.nix`) that recursively discovers and imports all `.nix` files with specific exclusions.

### Configuration Organization

- **`modules/`**: Core functionality modules by category (apps, cli, desktops, sys, hw)
- **`suites/`**: Grouped collections of modules for specific use cases
- **`systems/`**: Host-specific configurations
- **`settings/`**: JSON configuration files for user settings
- **`secrets/`**: JSON secrets file (referenced but not version controlled)

## Development Workflow

1. Use `just dev-test` for quick validation during development
2. Use `just dev-rebuild` to test changes on current system
3. Add trace flags when debugging module issues
4. Run `just nix-lint` before committing changes
5. Use `just garbage` periodically to clean up build artifacts

### Important Commands

- `just dev-test` - Dry-build nixos config without committing (fast iteration)
- `just dev-rebuild` - Rebuild nixos config without committing to git
- `just rebuild` - Standard system rebuild (commits to bootloader)
- `just upgrade-system` - Update flake inputs and rebuild with upgrade flag
- `just version-update` - Update flake dependencies

## Commit Guidelines

- Use conventional commits with emojis
- Write commit messages based strictly on git changes
- Ensure all commits are signed
- Never brand commits with "claude"

## Shell Aliases

- `gon`: Changes to the repository directory
- `rebuild`: Runs `just rebuild`
- `dev-rebuild`: Runs `just dev-rebuild`
