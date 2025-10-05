# Development Shell

## Overview

The nixcfg repository includes a development shell with tools for NixOS configuration development and system management.

## Entering the Development Environment

```bash
# Enter development shell
nix develop

# Or use direnv for automatic activation
echo "use flake" > .envrc && direnv allow
```

## Available Tools

### Nix Development Tools
- **nil**: Nix language server for IDE support
- **statix**: Static analysis and linting for Nix code
- **nixpkgs-fmt**: Official Nix code formatter

### NixOS Configuration Tools
- **just**: Command runner (primary workflow tool)
- **nixos-rebuild**: Direct system rebuild access
- **jq**: JSON processing for settings/secrets files

### System Analysis Tools
- **nix-tree**: Visualize Nix dependencies and build graphs
- **nix-du**: Analyze Nix store disk usage

## Primary Workflow Commands

### Development & Testing
```bash
just check         # Fast syntax validation
just test          # Dry-build validation
just build         # Build current system
just rebuild       # Full system rebuild
just lint          # Lint all Nix files
just clean         # Clean old generations
```

### Direct Tool Usage
```bash
statix check .              # Manual static analysis
nixpkgs-fmt **/*.nix       # Format Nix files
nix flake check            # Validate flake structure
nix-tree                   # Interactive dependency browser
```

## Development Workflow

1. **Enter development environment**: `nix develop`
2. **Make changes** to configuration files
3. **Validate syntax**: `just check`
4. **Test changes**: `just test` (dry-build)
5. **Apply changes**: `just build` or `just rebuild`
6. **Clean up**: `just clean` (periodically)

## Shell Features

The development shell provides:
- Current hostname display (helpful for multi-system development)
- Repository context information
- Command reference and help
- All necessary tools pre-configured and available