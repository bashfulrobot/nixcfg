{
  config,
  pkgs,
  lib,
  user-settings,
  ...
}:

with lib;
let
  cfg = config.apps.zoom-flatpak;
in
{
  options = {
    apps.zoom-flatpak = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable zoom desktop flatpak.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.flatpak.packages = [ "us.zoom.Zoom" ];

    home-manager.users."${user-settings.user.username}" = {
      xdg.mimeApps.defaultApplications = {
        "x-scheme-handler/zoom" = "us.zoom.Zoom.desktop";
        "x-scheme-handler/zoommtg" = "us.zoom.Zoom.desktop";
        "x-scheme-handler/zoomus" = "us.zoom.Zoom.desktop";
      };
    };
  };
}
