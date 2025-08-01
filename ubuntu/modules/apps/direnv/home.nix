# Home-manager implementation for direnv
{ config, pkgs, lib, ... }:

let
  cfg = config.cli.direnv;
in {
  # Only apply when in home-manager context
  config = lib.mkIf (cfg.enable && (config ? home)) {
    # Home Manager direnv configuration
    programs.direnv = {
      enable = true;
      # caching builds
      # https://github.com/nix-community/nix-direnv
      nix-direnv.enable = true;
      enableBashIntegration = cfg.enableBashIntegration;
      # enableFishIntegration handled automatically by home-manager
      config.global = {
        load_dotenv = true;
        strict_env = true;
        warn_timeout = cfg.warnTimeout;
      };
    };
  };
}