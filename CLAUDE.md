# CLAUDE.md

## Documentation References

- **Home Manager Options** - <https://home-manager-options.extranix.com/?query=hyprland&release=master> (hyprland is my search term, you can search whatever you want)
- **NixOs Options** - <https://search.nixos.org/options?channel=unstable&query=hyprland> (hyprland is my search term, you can search whatever you want)
- **NixOs Packages** - <https://search.nixos.org/packages?channel=unstable&query=hyprland> (hyprland is my search term, you can search whatever you want)

## Essential Commands

### Development & Testing

- `just check` - Fast syntax validation without building. Ran by user
- `just test` - Dry-build nixos config without committing (fast iteration). Ran by user
- `just rebuild` - Standard system rebuild (commits to bootloader). Ran by user
- `just rebuild trace=true` - Rebuild with trace output. Ran by user
- Use `stylix` to test files as well.
- NEVER RUN REBUILD OR TESTS UNLESS I EXPLICITLY ASK YOU.

### Module System

The repository uses an **auto-import** system (`lib/autoimport.nix`) that recursively discovers and imports all `.nix` files while excluding:

- `home-manager` directories
- `build` directories
- `disabled` directories
- `module-config` directories
- `imports.nix` itself

### Configuration Organization

- **`modules/`**: Core functionality modules organized by category
    - `apps/`: Browser wrappers and application configs
    - `cli/`: Command-line tools and terminal configurations
    - `desktops/`: Desktop environment configs (GNOME, tiling/Hyprland)
    - `sys/`: System-level configurations (fonts, power, etc.)
    - `hw/`: Hardware-specific configurations
- **`suites/`**: Grouped collections of modules for specific use cases
- **`hosts/`**: Host-specific configurations (donkeykong, qbert, srv)
- **`archetype/`**: System role definitions (workstation archetype)
- **`lib/`**: Utility functions (autoimport, browser wrappers, color conversion, desktop file creation)
- **`docs/`**: Comprehensive documentation and migration guides
- **`bootstrap/`**: System deployment and initialization scripts
- **`helpers/`**: Various utility scripts and references
- **`settings/`**: JSON configuration files for user settings
- **`secrets/`**: JSON secrets file (referenced but not version controlled)

## Configuration Files

- **User settings**: `settings/settings.json` - username, home path, user ID
- **System configs**: `hosts/{hostname}/config/modules.nix` - per-host module selection
- **Secrets**: `secrets/secrets.json` - sensitive configuration data

### Memories

### Feature Flag System

The repository uses a feature flag system at `~/.config/nix-flags/` to enable conditional behavior in build scripts:

- **Location**: `~/.config/nix-flags/`
- **Purpose**: Allow justfile commands to conditionally run features only when enabled
- **Implementation**: NixOS modules create flag files using home-manager's `home.file` option

#### Current Flag Files

- `gnome-enabled` - Created when `desktops.gnome.enable = true`
    - Enables GTK CSS fixes in `just build`, `just rebuild`, and `just upgrade`

#### Usage Pattern

**In NixOS modules** (create flag file):

```nix
home-manager.users."${user-settings.user.username}" = {
  home.file.".config/nix-flags/feature-name".text = "";
};
```

**In justfile** (check for flag):

```bash
if [[ -f "$HOME/.config/nix-flags/feature-name" ]]; then
  # Run feature-specific commands
fi
```

This system provides clean, declarative feature detection for build scripts without complex configuration parsing.
