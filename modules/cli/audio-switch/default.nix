{ config, lib, pkgs, user-settings, ... }:

let
  cfg = config.cli.audio-switch;
  
  makeScriptPackages = pkgs.callPackage ../../../lib/make-script-packages { };
  
  audioScripts = makeScriptPackages {
    scriptsDir = ./scripts;
    scripts = [
      "mv7"
      "rempods"
      "earmuffs"
      "mixed-mode-rempods"
      "mixed-mode-earmuffs"
      "speakers"
      "audio-list"
    ];
  };

in
{
  options.cli.audio-switch = {
    enable = lib.mkEnableOption "audio switching scripts";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = audioScripts.packages;

    # Add fish shell aliases
    programs.fish.shellAbbrs = lib.mkIf config.programs.fish.enable 
      audioScripts.fishShellAbbrs;
  };
}