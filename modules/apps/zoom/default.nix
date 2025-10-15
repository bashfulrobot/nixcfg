{
  config,
  pkgs,
  lib,
  user-settings,
  ...
}:

with lib;
let
  cfg = config.apps.zoom;
in
{
  options = {
    apps.zoom = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable zoom desktop application from nixpkgs.";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.unstable.zoom-us ];

    home-manager.users."${user-settings.user.username}" = {
      # Custom desktop file with explicit browser environment
      home.file.".local/share/applications/zoom.desktop".text = ''
        [Desktop Entry]
        Name=Zoom
        Comment=Zoom Video Conference
        GenericName=Zoom Client for Linux
        Exec=env BROWSER=/run/current-system/sw/bin/chromium ${pkgs.zoom-us}/bin/zoom %U
        Icon=Zoom
        Terminal=false
        Type=Application
        StartupNotify=true
        Categories=Network;InstantMessaging;VideoConference;Telephony;
        MimeType=x-scheme-handler/zoommtg;x-scheme-handler/zoomus;x-scheme-handler/tel;x-scheme-handler/callto;x-scheme-handler/zoomphonecall;application/x-zoom
        X-KDE-Protocols=zoommtg;zoomus;tel;callto;zoomphonecall;
        StartupWMClass=zoom
      '';

      # Ensure desktop database is updated for protocol handlers
      home.activation.updateDesktopDatabase = lib.mkAfter ''
        $DRY_RUN_CMD ${pkgs.desktop-file-utils}/bin/update-desktop-database $HOME/.local/share/applications
      '';

      # MIME type associations for zoom protocol handlers
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "x-scheme-handler/zoom" = [ "zoom.desktop" ];
          "x-scheme-handler/zoommtg" = [ "zoom.desktop" ];
          "x-scheme-handler/zoomus" = [ "zoom.desktop" ];
          "x-scheme-handler/zoomphonecall" = [ "zoom.desktop" ];
          "x-scheme-handler/zoomauthenticator" = [ "zoom.desktop" ];
          "x-scheme-handler/tel" = [ "zoom.desktop" ];
          "x-scheme-handler/callto" = [ "zoom.desktop" ];
        };
        associations.added = {
          "x-scheme-handler/zoom" = [ "zoom.desktop" ];
          "x-scheme-handler/zoommtg" = [ "zoom.desktop" ];
          "x-scheme-handler/zoomus" = [ "zoom.desktop" ];
          "x-scheme-handler/zoomphonecall" = [ "zoom.desktop" ];
          "x-scheme-handler/zoomauthenticator" = [ "zoom.desktop" ];
          "x-scheme-handler/tel" = [ "zoom.desktop" ];
          "x-scheme-handler/callto" = [ "zoom.desktop" ];
        };
      };
    };
  };
}
