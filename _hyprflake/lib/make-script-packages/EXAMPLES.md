# makeScriptPackages Enhanced Usage Examples

This document demonstrates the enhanced makeScriptPackages library with runtimeInputs support.

## Basic Usage (Backward Compatible)

```nix
# Simple string-based scripts (unchanged from before)
basicScripts = makeScriptPackages {
  scriptsDir = ./scripts;
  scripts = [ "backup" "sync" ];
};
```

## Global runtimeInputs

```nix
# All scripts get the same runtime dependencies
spotifyScripts = makeScriptPackages {
  scriptsDir = ./scripts;
  scripts = [ "ncspot-save-playing" "spotify-status" ];
  runtimeInputs = with pkgs; [ netcat-gnu jq libnotify ];
};
```

## Per-Script runtimeInputs

```nix
# Individual scripts with specific dependencies
mixedScripts = makeScriptPackages {
  scriptsDir = ./scripts;
  scripts = [
    "simple-script"  # Uses writeShellScriptBin (no deps)
    {
      name = "api-script";
      runtimeInputs = with pkgs; [ curl jq ];
    }
    {
      name = "notification-script";
      runtimeInputs = with pkgs; [ libnotify ];
    }
  ];
};
```

## Combined Global and Per-Script runtimeInputs

```nix
# Global deps + per-script additional deps
complexScripts = makeScriptPackages {
  scriptsDir = ./scripts;
  scripts = [
    "base-script"  # Gets global deps only
    {
      name = "enhanced-script";
      runtimeInputs = with pkgs; [ gum fzf ];  # Gets global + these
    }
  ];
  runtimeInputs = with pkgs; [ coreutils findutils ];  # Global for all
};
```

## Advanced Configuration

```nix
# All features combined
advancedScripts = makeScriptPackages {
  scriptsDir = ./scripts;
  scripts = [
    "simple"
    {
      name = "complex";
      command = "my-complex-cmd";  # Custom command name
      runtimeInputs = with pkgs; [ docker podman ];
    }
  ];
  runtimeInputs = with pkgs; [ git ];  # Global dependency
  scriptMap = {
    simple = "simple-command";  # Global command mapping
  };
  createFishAbbrs = true;  # Fish shell abbreviations
};
```

## Implementation Details

### When writeShellApplication is Used

- When global `runtimeInputs` are specified
- When per-script `runtimeInputs` are specified
- When both global and per-script `runtimeInputs` exist (they are merged)

### When writeShellScriptBin is Used

- When no `runtimeInputs` are specified anywhere (maintains backward compatibility)
- Provides the same behavior as the original implementation

### Runtime Dependencies Merging

```nix
# Global: [ git curl ]
# Per-script: [ jq gum ]
# Result: [ git curl jq gum ]
```

The global runtimeInputs are applied first, followed by per-script runtimeInputs, ensuring proper dependency resolution.