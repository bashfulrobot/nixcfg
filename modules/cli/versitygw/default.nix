{ user-settings, pkgs, config, lib, ... }:

let
  cfg = config.cli.versitygw;
  versitygw = pkgs.callPackage ./build { };

in {

  options = {
    cli.versitygw.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable versitygw.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [

      # keep-sorted start case=no numeric=yes
      versitygw
      # keep-sorted end
    ];
    # home-manager.users."${user-settings.user.username}" = {

    # };
  };
}
