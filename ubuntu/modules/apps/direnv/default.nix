# Direnv module with structured co-location
# Provides both home-manager and system-manager configuration
{ config, lib, ... }:

let
  cfg = config.cli.direnv;
in {
  options.cli.direnv = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable direnv with system packages and user configuration";
    };
  };

  # Import context-specific implementations
  imports = [
    ./home.nix
    ./system.nix
  ];
}