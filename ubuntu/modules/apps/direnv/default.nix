# Direnv module with structured co-location
# Provides both home-manager and system-manager configuration
{ lib, ... }:

{
  # Shared options for direnv across contexts
  options.cli.direnv = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable direnv with system packages and user configuration";
    };
    
    enableBashIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable bash integration for direnv";
    };
    
    warnTimeout = lib.mkOption {
      type = lib.types.str;
      default = "400ms";
      description = "Warning timeout for direnv";
    };
  };

  # Import context-specific implementations
  imports = [
    ./home.nix
    ./system.nix
  ];
}