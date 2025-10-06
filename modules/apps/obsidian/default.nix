{ user-settings, pkgs, config, lib, ... }:
let cfg = config.apps.obsidian;

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

      # keep-sorted start case=no numeric=yes
      obsidian
      obsidian-export
      # vimPlugins.obsidian-nvim
      # keep-sorted end
    ];
  };
}
