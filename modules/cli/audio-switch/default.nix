{ config, lib, pkgs, user-settings, ... }:

let
  cfg = config.cli.audio-switch;

  # Audio switching script packages using standard pattern
  audioScripts = with pkgs; [
    (writeShellScriptBin "mv7" (builtins.readFile ./scripts/mv7.sh))
    (writeShellScriptBin "rempods" (builtins.readFile ./scripts/rempods.sh))
    (writeShellScriptBin "earmuffs" (builtins.readFile ./scripts/earmuffs.sh))
    (writeShellScriptBin "mixed-mode-rempods" (builtins.readFile ./scripts/mixed-mode-rempods.sh))
    (writeShellScriptBin "mixed-mode-earmuffs" (builtins.readFile ./scripts/mixed-mode-earmuffs.sh))
    (writeShellScriptBin "speakers" (builtins.readFile ./scripts/speakers.sh))
    (writeShellScriptBin "audio-list" (builtins.readFile ./scripts/audio-list.sh))
  ];

in
{
  options.cli.audio-switch = {
    enable = lib.mkEnableOption "audio switching scripts";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = audioScripts;

    # Add fish shell aliases for convenience
    programs.fish.shellAbbrs = lib.mkIf config.programs.fish.enable {
      "mv7" = "mv7";
      "rempods" = "rempods";
      "earmuffs" = "earmuffs";
      "mmr" = "mixed-mode-rempods";
      "mme" = "mixed-mode-earmuffs";
      "speakers" = "speakers";
      "audio-list" = "audio-list";
    };
  };
}