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

    services.flatpak.overrides = {
      "us.zoom.Zoom" = {
        Context.shared = [ "network" "ipc" ];  # Add IPC for process communication
        Context.filesystems = [
          "host-etc:ro"  # Access to /etc for NixOS user profiles
          "/run/current-system/sw/bin:ro"  # System binaries
        ];
        Context.talks = [
          "org.freedesktop.portal.Desktop"  # Desktop portal for launching apps
          "org.freedesktop.portal.OpenURI"  # URI opening portal
        ];
        Environment = {
          XDG_CURRENT_DESKTOP = "COSMIC";
        };
      };
    };

    home-manager.users."${user-settings.user.username}" = {
      # Custom desktop file with explicit browser environment
      home.file.".local/share/applications/us.zoom.Zoom.desktop".text = ''
        [Desktop Entry]
        Name=Zoom
        Comment=Zoom Video Conference
        GenericName=Zoom Client for Linux
        Exec=env BROWSER=/run/current-system/sw/bin/vivaldi /var/lib/flatpak/exports/bin/us.zoom.Zoom %U
        Icon=us.zoom.Zoom
        Terminal=false
        Type=Application
        StartupNotify=true
        Categories=Network;InstantMessaging;VideoConference;Telephony;
        MimeType=x-scheme-handler/zoommtg;x-scheme-handler/zoomus;x-scheme-handler/tel;x-scheme-handler/callto;x-scheme-handler/zoomphonecall;application/x-zoom
        X-KDE-Protocols=zoommtg;zoomus;tel;callto;zoomphonecall;
        StartupWMClass=zoom
        X-Flatpak-Tags=proprietary;
        X-Flatpak=us.zoom.Zoom
      '';

      # Ensure desktop database is updated for protocol handlers
      home.activation.updateDesktopDatabase = lib.mkAfter ''
        $DRY_RUN_CMD ${pkgs.desktop-file-utils}/bin/update-desktop-database $HOME/.local/share/applications
      '';

      # KEPT: Original + associations.added (helpful for overall MIME handling)
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "x-scheme-handler/zoom" = [ "us.zoom.Zoom.desktop" ];
          "x-scheme-handler/zoommtg" = [ "us.zoom.Zoom.desktop" ];
          "x-scheme-handler/zoomus" = [ "us.zoom.Zoom.desktop" ];
          "x-scheme-handler/zoomphonecall" = [ "us.zoom.Zoom.desktop" ];
          "x-scheme-handler/zoomauthenticator" = [ "us.zoom.Zoom.desktop" ];
          "x-scheme-handler/tel" = [ "us.zoom.Zoom.desktop" ];
          "x-scheme-handler/callto" = [ "us.zoom.Zoom.desktop" ];
        };
        associations.added = {
          "x-scheme-handler/zoom" = [ "us.zoom.Zoom.desktop" ];
          "x-scheme-handler/zoommtg" = [ "us.zoom.Zoom.desktop" ];
          "x-scheme-handler/zoomus" = [ "us.zoom.Zoom.desktop" ];
          "x-scheme-handler/zoomphonecall" = [ "us.zoom.Zoom.desktop" ];
          "x-scheme-handler/zoomauthenticator" = [ "us.zoom.Zoom.desktop" ];
          "x-scheme-handler/tel" = [ "us.zoom.Zoom.desktop" ];
          "x-scheme-handler/callto" = [ "us.zoom.Zoom.desktop" ];
        };
      };
    };
  };
}
