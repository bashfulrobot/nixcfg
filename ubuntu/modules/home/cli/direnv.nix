{ config, pkgs, lib, ... }:
# Direnv user configuration with nix-direnv integration

{
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;

      config.global = {
        load_dotenv = true;
        strict_env = true;
        warn_timeout = "400ms";
      };
    };
}