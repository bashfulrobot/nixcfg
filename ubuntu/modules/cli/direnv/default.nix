# Direnv module with structured co-location
# Provides both home-manager and system-manager configuration
{ config, pkgs, lib, ... }:

let
  cfg = config.cli.direnv;
in {

options = {
    cli.direnv.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the direnv tool.";
    };
  };

  # Apply configuration directly in this file
  config = lib.mkIf cfg.enable {
    # System-level configuration
    environment.systemPackages = with pkgs; [
      direnv
    ];

    # Home-manager configuration
    home-manager.users = lib.mkIf (config ? home-manager) (lib.genAttrs
      (lib.attrNames (config.home-manager.users or {}))
      (user: {
        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
          enableBashIntegration = true;

          config.global = {
            load_dotenv = true;
            strict_env = true;
            warn_timeout = "400ms";
          };
        };
      })
    );
  };
}