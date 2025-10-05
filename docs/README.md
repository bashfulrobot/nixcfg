# NixOS Configuration Documentation

Documentation for Dustin Krysak's comprehensive NixOS configuration repository.

## Quick References

- [Development Shell](development/shell.md) - Development environment and workflow
- [Architecture Overview](architecture/) - System design and module organization
- [Module Documentation](modules/) - Individual module guides and examples

## Repository Structure

This repository manages multiple NixOS systems with a modular, declarative approach using Nix flakes.

### Key Directories
- `hosts/` - Host-specific configurations (donkeykong, qbert, srv)
- `modules/` - Core functionality modules organized by category
- `suites/` - Grouped collections of modules for specific use cases
- `settings/` - JSON configuration files for user settings
- `secrets/` - JSON secrets file (not version controlled)

For detailed architecture information, see the [Architecture Overview](architecture/).

## Essential Commands

All development and system management is done through the `just` command runner. See [Development Shell](development/shell.md) for complete workflow documentation.