{ user-settings, lib, pkgs, config, ... }:
let
  cfg = config.cli.sitemcp;
  sitemcp = pkgs.callPackage ./build { };

in
{
  options = {
    cli.sitemcp.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable sitemcp - fetch entire sites as MCP servers.";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${user-settings.user.username}" = {
      home.packages = [ sitemcp ];

      # Add fish abbreviation for quick access
      programs.fish.shellAbbrs = {
        smcp = "sitemcp";
      };
    };
  };
}