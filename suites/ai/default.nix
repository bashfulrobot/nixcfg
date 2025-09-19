{
  config,
  pkgs,
  lib,
  user-settings,
  ...
}:
let
  cfg = config.suites.ai;
in
{

  options = {
    suites.ai.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable AI tooling..";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      inputs.nixai.packages.${pkgs.system}.default # AI-Powered NixOS Companion

    ];

    cli = {
      claude-code.enable = true;
      gemini-cli.enable = true;
    };

    home-manager.users."${user-settings.user.username}" = {

    };
  };
}
