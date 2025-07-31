# Ubuntu Home Manager Configuration

This directory contains a dedicated home-manager flake configuration for Ubuntu systems, specifically for the `donkey-kong` host.

## Quick Start

### First Time Setup (on Ubuntu)

1. **Install Nix with flakes support:**
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. **Clone this repo and navigate to ubuntu-home:**
   ```bash
   cd /path/to/nixcfg/ubuntu-home
   ```

3. **Initialize home-manager:**
   ```bash
   nix run github:nix-community/home-manager/release-25.05 -- switch --flake .#dustin@donkey-kong
   ```

### Daily Usage

Use the provided justfile commands:

```bash
# Test configuration without applying
just home-test

# Apply new configuration
just home-rebuild  

# Update flake inputs and rebuild
just home-update

# Show what would change
just home-diff

# Debug with trace output
just home-rebuild-trace
```

## Structure

- `flake.nix` - Main flake configuration with inputs and home-manager setup
- `hosts/donkey-kong/` - Host-specific configuration
  - `default.nix` - Basic home-manager settings and system packages
  - `modules.nix` - Module imports and enablement
- `modules/` - Local modules (currently empty, imports from parent `../modules/`)
- `settings/` - Configuration settings (copied from parent)
- `justfile` - Development commands

## Module Selection

The configuration imports compatible modules from the parent NixOS configuration:

### Currently Enabled
- **CLI Tools:** git, fish, starship, helix, direnv, yazi, alacritty, nixvim, zellij, kubie
- **Base packages:** development tools, system utilities

### Available but Commented
- Additional terminal emulators (kitty, foot, wezterm, ghostty)
- Development environments (go, nix)
- Browser wrappers (zen-browser, vscode)
- System theming (fonts, gtk-theme, xdg)

## Adding More Modules

1. **From parent directory:** Uncomment imports in `modules.nix`
2. **New modules:** Add to local `modules/` directory
3. **Enable modules:** Add to the enable block in `modules.nix`

## Troubleshooting

- **Build errors:** Use `just home-rebuild-trace` for detailed output
- **Module conflicts:** Check that modules support home-manager vs NixOS
- **Old generations:** Use `just home-cleanup` to remove old builds

## Integration

This setup reuses:
- Settings from `../settings/settings.json`
- Secrets from `../secrets/secrets.json` 
- Compatible modules from `../modules/`

Changes to the parent settings will affect this configuration after rebuild.