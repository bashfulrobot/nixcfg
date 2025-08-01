{ config, pkgs, lib, ... }:

let
  cfg = config.cli.direnv;
in {
  options.cli.direnv = {
    enable = lib.mkEnableOption "Enable direnv user configuration with nix-direnv integration and bash support";
  };

  config = lib.mkIf cfg.enable {
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
  };
}