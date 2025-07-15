# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a comprehensive NixOS configuration repository for Dustin Krysak, managing multiple systems (digdug, qbert, srv) with a modular, declarative approach. The repository uses Nix flakes for dependency management and includes configurations for both workstations and servers.

## Essential Commands

### Development & Testing
- `just dev-test` - Dry-build nixos config without committing (fast iteration)
- `just dev-rebuild` - Rebuild nixos config without committing to git
- `just dev-rebuild-trace` - Rebuild with trace output for debugging
- `just dev-test-trace` - Test build with trace output

### Production Operations
- `just rebuild` - Standard system rebuild (commits to bootloader)
- `just final-build-reboot` - Full garbage collection, rebuild, and reboot
- `just upgrade-system` - Update flake inputs and rebuild with upgrade flag

### Maintenance
- `just garbage` - Clean packages older than 5 days
- `just garbage-build-cache` - Full garbage collection
- `just nix-lint` - Lint all nix files using statix
- `just version-update` - Update flake dependencies

### Darwin (macOS) Systems
- `just darwin-rebuild` - Rebuild Darwin systems in nix-darwin/
- `just darwin-upgrade-system` - Update and rebuild Darwin systems

## Architecture

### Flake Structure
- **Inputs**: Multiple channels (stable 24.11, unstable), home-manager, hardware configs, specialized tools
- **Systems**: Three main configurations (digdug/qbert as workstations, srv as server)
- **Overlays**: Unstable packages available under `pkgs.unstable`
- **specialArgs**: User settings, secrets, and isWorkstation flag passed to all modules

### Module System
The repository uses an **auto-import** system (`autoimport.nix`) that recursively discovers and imports all `.nix` files while excluding:
- `home-manager` directories
- `build` directories 
- `disabled` directories
- `module-config` directories
- `autoimport.nix` itself

### Configuration Organization
- **`modules/`**: Core functionality modules organized by category
  - `apps/`: Browser wrappers and application configs
  - `cli/`: Command-line tools and terminal configurations
  - `desktops/`: Desktop environment configs (GNOME, Hyprland)
  - `sys/`: System-level configurations (fonts, power, etc.)
  - `hw/`: Hardware-specific configurations
- **`suites/`**: Grouped collections of modules for specific use cases
- **`systems/`**: Host-specific configurations
- **`settings/`**: JSON configuration files for user settings
- **`secrets/`**: JSON secrets file (referenced but not version controlled)

### Key Patterns
- Modules use option-based enabling: `desktops.gnome.enable = true`
- Host-specific toggles: `apps.syncthing.host.qbert = true`
- Settings loaded from JSON: `user-settings` and `secrets` available in all modules
- Conditional logic based on `isWorkstation` parameter

### Build System Notes
- Uses `hostname` for automatic host detection in justfile commands
- Shell set to fish for justfile execution
- Trace output captured to `~/dev/nix/nixcfg/rebuild-trace.log`
- Flake lock backups created with timestamps during upgrades

## Configuration Files
- **User settings**: `settings/settings.json` - username, home path, user ID
- **System configs**: `systems/{hostname}/config/modules.nix` - per-host module selection
- **Secrets**: `secrets/secrets.json` - sensitive configuration data

## Development Workflow
1. Use `just dev-test` for quick validation during development
2. Use `just dev-rebuild` to test changes on current system
3. Add trace flags when debugging module issues
4. Run `just nix-lint` before committing changes
5. Use `just garbage` periodically to clean up build artifacts

### Memories
- `just rebuild` - Standard system rebuild that commits to bootloader
- there are shell aliases to interact with this repo: `gon` changes to the repo. `rebuild` runs `just rebuild`, and `dev-rebuild` runs `just dev-rebuild`
- never brand commits with claude.
- As a DevOps Sr. Professional, follow best practices by:
  - Using conventional commits with emojis
  - Being extra careful to write commit messages based strictly on git changes
  - Ensuring all commits are signed
