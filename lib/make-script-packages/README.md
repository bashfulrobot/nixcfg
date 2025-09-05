# Make Script Packages Library

A Nix library for efficiently creating and managing shell script packages in NixOS configurations. Eliminates boilerplate code when packaging multiple shell scripts into system packages.

## Problem Solved

Before this library, packaging shell scripts required repetitive code:

```nix
let
  script1 = pkgs.writeShellScriptBin "script1" (builtins.readFile ./scripts/script1.sh);
  script2 = pkgs.writeShellScriptBin "script2" (builtins.readFile ./scripts/script2.sh);
  script3 = pkgs.writeShellScriptBin "script3" (builtins.readFile ./scripts/script3.sh);
in {
  environment.systemPackages = [ script1 script2 script3 ];
  programs.fish.shellAbbrs = {
    script1 = "script1";
    script2 = "script2"; 
    script3 = "script3";
  };
}
```

Now it's just:

```nix
let
  makeScriptPackages = pkgs.callPackage ../../../lib/make-script-packages { };
  scripts = makeScriptPackages {
    scriptsDir = ./scripts;
    scripts = [ "script1" "script2" "script3" ];
  };
in {
  environment.systemPackages = scripts.packages;
  programs.fish.shellAbbrs = scripts.fishShellAbbrs;
}
```

## Basic Usage

### Simple Script List

```nix
let
  makeScriptPackages = pkgs.callPackage ../../../lib/make-script-packages { };
  audioScripts = makeScriptPackages {
    scriptsDir = ./scripts;
    scripts = [ "mv7" "rempods" "speakers" "headphones" ];
  };
in {
  environment.systemPackages = audioScripts.packages;
  programs.fish.shellAbbrs = lib.mkIf config.programs.fish.enable 
    audioScripts.fishShellAbbrs;
}
```

**Requirements:**
- Script files must have `.sh` extension (`mv7.sh`, `rempods.sh`, etc.)
- Command names match script names by default
- Must specify `scriptsDir` parameter pointing to directory containing scripts

## Advanced Usage

### Custom Script Directory

```nix
audioScripts = makeScriptPackages {
  scriptsDir = ./my-custom-scripts;
  scripts = [ "script1" "script2" ];
};
```

### Custom Command Names

```nix
audioScripts = makeScriptPackages {
  scripts = [
    "mv7"                                    # Command: mv7
    { name = "rempods"; command = "remote-pods"; }  # Command: remote-pods
    "speakers"                               # Command: speakers
  ];
};
```

### Global Command Mapping

```nix
audioScripts = makeScriptPackages {
  scripts = [ "audio-list" "audio-switch" ];
  scriptMap = {
    "audio-list" = "list-audio";
    "audio-switch" = "switch-audio";
  };
};
```

### Disable Fish Abbreviations

```nix
audioScripts = makeScriptPackages {
  scripts = [ "script1" "script2" ];
  createFishAbbrs = false;  # No fish abbreviations generated
};
```

### Mixed Configuration

```nix
audioScripts = makeScriptPackages {
  scriptsDir = ./audio-scripts;
  scripts = [
    "mv7"                                          # Uses global mapping if exists
    { name = "rempods"; command = "remote-pods"; } # Per-script override
    "speakers"
    { name = "audio-list"; command = "list-audio"; }
  ];
  scriptMap = {
    "mv7" = "microphone-mv7";  # Global mapping for mv7
  };
  createFishAbbrs = true;
};
```

## API Reference

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `scriptsDir` | path | required | Directory containing script files |
| `scripts` | list | required | List of script names or configuration objects |
| `createFishAbbrs` | bool | `true` | Whether to generate fish shell abbreviations |
| `scriptMap` | attrs | `{}` | Global script-to-command name mappings |

### Script Configuration Objects

When using objects in the `scripts` list:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | yes | Script file name (without .sh) |
| `command` | string | no | Custom command name (defaults to `name`) |

### Return Value

The function returns an attribute set with:

| Field | Type | Description |
|-------|------|-------------|
| `packages` | list | Script packages for `environment.systemPackages` |
| `fishShellAbbrs` | attrs | Abbreviations for `programs.fish.shellAbbrs` |
| `scriptNames` | list | List of script file names (debugging) |
| `commandNames` | list | List of command names (debugging) |

## File Structure Requirements

```
your-module/
├── default.nix
└── scripts/
    ├── script1.sh
    ├── script2.sh
    └── script3.sh
```

All script files must:
- Have `.sh` extension
- Be executable shell scripts
- Exist in the specified `scriptsDir`

## Error Handling

The library will throw clear errors if:
- Script files don't exist: `"Script file not found: /path/to/script.sh"`
- Required parameters are missing

## Integration with Module System

### Complete Module Example

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.cli.audio-switch;
  
  makeScriptPackages = pkgs.callPackage ../../../lib/make-script-packages { };
  
  audioScripts = makeScriptPackages {
    scriptsDir = ./scripts;
    scripts = [
      "mv7"
      "rempods"
      "earmuffs" 
      { name = "mixed-mode-rempods"; command = "mm-rempods"; }
      { name = "mixed-mode-earmuffs"; command = "mm-earmuffs"; }
      "speakers"
      "audio-list"
    ];
  };

in {
  options.cli.audio-switch = {
    enable = lib.mkEnableOption "audio switching scripts";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = audioScripts.packages;
    
    programs.fish.shellAbbrs = lib.mkIf config.programs.fish.enable
      audioScripts.fishShellAbbrs;
  };
}
```

## Benefits

- **Eliminates boilerplate**: No more repetitive `writeShellScriptBin` calls
- **Single source of truth**: Script list defined once
- **Automatic fish integration**: Shell abbreviations generated automatically  
- **Flexible naming**: Custom command names supported
- **Error prevention**: Can't forget to add scripts to packages or abbreviations
- **Easy maintenance**: Adding new scripts requires only updating the list
- **Debugging support**: Returns script and command lists for troubleshooting

## Migration from Existing Code

To migrate existing script packaging:

1. **Identify the pattern**: Look for multiple `pkgs.writeShellScriptBin` calls
2. **Extract script names**: List all script names from the existing code
3. **Replace with library call**: Use `makeScriptPackages` with the script list
4. **Update references**: Replace package list and fish abbreviations with library returns
5. **Test**: Verify all scripts are still available after rebuild

The library maintains backward compatibility - your scripts will work exactly the same way, just with less code to maintain.