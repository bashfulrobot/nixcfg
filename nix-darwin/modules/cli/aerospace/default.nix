{ user-settings, config, lib, pkgs, ... }:
let
  cfg = config.cli.aerospace;
  # yabai = "${pkgs.yabai}/bin/yabai";
  # jq = "${pkgs.jq}/bin/jq";
in {
  options = {
    cli.aerospace.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Aerospace tiling manager.";
    };
  };

  config = lib.mkIf cfg.enable {

    homebrew = {
      taps = [ "nikitabobko/tap" ];
      casks = [ "nikitabobko/tap/aerospace" ];
      };

    home-manager.users."${user-settings.user.username}" = {
      xdg.configFile."aerospace/aerospace.toml".source = ./aerospace.toml;

      xdg.configFile."aerospace/aerospace.toml".onChange =
        "/opt/homebrew/bin/aerospace reload-config";

    };

  };
}
