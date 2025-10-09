{ user-settings, pkgs, config, lib, ... }:
let
  cfg = config.cli.oq;
  oq = pkgs.callPackage ./build { };
in {
  options = {
    cli.oq.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable oq - Terminal-based OpenAPI Spec (OAS) viewer.";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${user-settings.user.username}" = {
      home.packages = [ oq ];
    };
  };
}