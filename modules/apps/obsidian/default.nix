{ user-settings, pkgs, config, lib, ... }:
let
  cfg = config.apps.obsidian;

in {

  options = {
    apps.obsidian.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Obsidian Notes.";
    };
  };

  config = lib.mkIf cfg.enable {

    # Install necessary packages
    environment.systemPackages = with pkgs; [
      obsidian
      obsidian-export
      theme-obsidian2
      iconpack-obsidian
      # vimPlugins.obsidian-nvim
    ];
