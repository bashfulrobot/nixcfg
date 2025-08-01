# Direnv Module

Provides comprehensive direnv support across both user and system contexts.

## Configuration

Enable direnv with:
```nix
cli.direnv.enable = true;
```

## What it provides

### Home Manager Context
- User direnv configuration via `programs.direnv`
- Nix-direnv integration for caching builds
- Bash integration (configurable)
- Automatic fish integration when fish is enabled
- Global configuration (load_dotenv, strict_env, warn_timeout)

### System Manager Context  
- System-wide direnv package installation
- envsubst utility for environment substitution
- Makes direnv available to all users

## Options

- `cli.direnv.enable` - Enable direnv (both contexts)
- `cli.direnv.enableBashIntegration` - Enable bash integration (default: true)
- `cli.direnv.warnTimeout` - Warning timeout (default: "400ms")

## Architecture

This module uses structured co-location:
- `default.nix` - Shared options and imports
- `home.nix` - Home-manager specific configuration  
- `system.nix` - System-manager specific configuration
- `README.md` - Documentation for both contexts

Each context is automatically detected and only applies its relevant configuration.