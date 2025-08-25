{ config, lib, pkgs, user-settings, ... }:

let
  cfg = config.cli.audio-switch;

  # Create scripts from external files
  mv7-script = pkgs.writeShellScriptBin "mv7" (builtins.readFile ./scripts/mv7.sh);
  rempods-script = pkgs.writeShellScriptBin "rempods" (builtins.readFile ./scripts/rempods.sh);
  earmuffs-script = pkgs.writeShellScriptBin "earmuffs" (builtins.readFile ./scripts/earmuffs.sh);
  mixed-mode-rempods-script = pkgs.writeShellScriptBin "mixed-mode-rempods" (builtins.readFile ./scripts/mixed-mode-rempods.sh);
  mixed-mode-earmuffs-script = pkgs.writeShellScriptBin "mixed-mode-earmuffs" (builtins.readFile ./scripts/mixed-mode-earmuffs.sh);
  speakers-script = pkgs.writeShellScriptBin "speakers" (builtins.readFile ./scripts/speakers.sh);
  audio-list-script = pkgs.writeShellScriptBin "audio-list" (builtins.readFile ./scripts/audio-list.sh);

in
{
  options.cli.audio-switch = {
    enable = lib.mkEnableOption "audio switching scripts";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      mv7-script
      rempods-script
      earmuffs-script
      mixed-mode-rempods-script
      mixed-mode-earmuffs-script
      speakers-script
      audio-list-script
    ];

    # Add fish shell aliases
    programs.fish.shellAbbrs = lib.mkIf config.programs.fish.enable {
      mv7 = "mv7";
      rempods = "rempods";
      earmuffs = "earmuffs";
      mixed-mode-rempods = "mixed-mode-rempods";
      mixed-mode-earmuffs = "mixed-mode-earmuffs";
      speakers = "speakers";
      audio-list = "audio-list";
    };
  };
}