{ user-settings, pkgs, config, lib, ... }:

let
  cfg = config.cli.catwalk;
  catwalk = pkgs.callPackage ./build { };

in {

  options = {
    cli.catwalk.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Catwalk - A database for Crush-compatible models.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [

      # keep-sorted start case=no numeric=yes
      catwalk
      # keep-sorted end
    ];
    
    home-manager.users."${user-settings.user.username}" = {
      # Add any home-manager configuration for catwalk here if needed
    };
  };
}