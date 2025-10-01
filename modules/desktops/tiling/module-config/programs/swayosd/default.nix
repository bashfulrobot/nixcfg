{
  user-settings,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.desktops.tiling.hyprland;
in
{
  options = {
    desktops.tiling.hyprland.swayosd.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable swayosd On-Screen Display for Hyprland";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.swayosd.enable) {
    home-manager.users."${user-settings.user.username}" = {
      services.swayosd = {
        enable = true;
        package = pkgs.swayosd;
        topMargin = 0.9; # Position OSD towards bottom of screen
        stylePath = null; # Use default styling for now
      };
    };
  };
}