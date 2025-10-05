{
  config,
  pkgs,
  lib,
  user-settings,
  inputs,
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

      #lmstudio # Local LLMs management tool

      # nix-ai-tools packages
      inputs.nix-ai-tools.packages.${pkgs.system}.backlog-md
      # unstable.code-cursor # Ai code editor
    ];

    cli = {
      claude-code.enable = true;
      gemini-cli.enable = true;
      catwalk.enable = false;
      crush.enable = false;
    };

    home-manager.users."${user-settings.user.username}" = {

    };
  };
}
