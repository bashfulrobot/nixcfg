{
  user-settings,
  pkgs,
  secrets,
  config,
  lib,
  ...
}:
let
  cfg = config.cli.eza;

in
{
  options = {
    cli.eza.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable eza, a modern replacement for ls.";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${user-settings.user.username}" = {
      programs.eza = {
        enable = true;
        colors = "auto";
        git = true;
        icons = "auto";
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        extraOptions = [
          "--long"
          "--all"
          "--octal-permissions"
          "--group-directories-first"
          "--time-style=long-iso"
        ];
      };
    };
  };
}