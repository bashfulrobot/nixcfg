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

      # keep-sorted start case=no numeric=yes

      #lmstudio # Local LLMs management tool

      # nix-ai-tools packages
      inputs.nix-ai-tools.packages.${pkgs.system}.backlog-md
      inputs.nixai.packages.${pkgs.system}.default # AI-Powered NixOS Companion
      # unstable.code-cursor # Ai code editor
      # keep-sorted end
    ];

    cli = {
      claude-code.enable = true;
      gemini-cli.enable = true;
      catwalk.enable = false;
      crush.enable = false;
      zed-ai.enable = true;
    };

    home-manager.users."${user-settings.user.username}" = {

    };
  };
}
