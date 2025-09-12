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
        Context.filesystems = [
          "/etc/profiles/per-user/${user-settings.user.username}:ro"
        ];
        Context.shared = [ "network" ];  # Ensure network sharing
        Context.talks = [
          "org.freedesktop.portal.Desktop"  # Desktop portal access
          "org.freedesktop.portal.Documents"  # Document portal access
          "org.freedesktop.impl.portal.desktop.cosmic"  # COSMIC desktop portal
          "org.freedesktop.impl.portal.desktop.gtk"  # GTK desktop portal
        ];
        # Context.system-talks = [
        #   "org.freedesktop.portal.Desktop"  # System-level portal access
        # ];
        Environment = {
          PATH = "/etc/profiles/per-user/${user-settings.user.username}/bin:/app/bin:/usr/bin";
          # BROWSER is now set by individual browser modules when setAsDefault = true
          XDG_CURRENT_DESKTOP = "COSMIC";  # Use COSMIC instead of GNOME
        };
      };
    };

    home-manager.users."${user-settings.user.username}" = {
      # COMMENTED OUT FOR TESTING: Custom desktop file creation
      # # Create local desktop file to ensure proper MIME handling
      # # This replicates the manual fix from forum posts
      # home.file.".local/share/applications/us.zoom.Zoom.desktop".text = ''
      #   [Desktop Entry]
      #   Name=Zoom
      #   Comment=Zoom Video Conference
      #   GenericName=Zoom Client for Linux
      #   Exec=flatpak run --branch=stable --arch=x86_64 --command=zoom --file-forwarding us.zoom.Zoom @@u %U @@
      #   Icon=us.zoom.Zoom
      #   Terminal=false
      #   Type=Application
      #   StartupNotify=true
      #   Categories=Network;InstantMessaging;VideoConference;Telephony;
      #   MimeType=x-scheme-handler/zoommtg;x-scheme-handler/zoomus;x-scheme-handler/tel;x-scheme-handler/callto;x-scheme-handler/zoomphonecall;application/x-zoom
      #   X-KDE-Protocols=zoommtg;zoomus;tel;callto;zoomphonecall;
      #   StartupWMClass=zoom
      #   X-Flatpak-Tags=proprietary;
      #   X-Flatpak=us.zoom.Zoom
      # '';

      # COMMENTED OUT FOR TESTING: Desktop database update
      # # Ensure desktop database is updated for protocol handlers
      # home.activation.updateDesktopDatabase = lib.mkAfter ''
      #   $DRY_RUN_CMD ${pkgs.desktop-file-utils}/bin/update-desktop-database $HOME/.local/share/applications
      # '';

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

      # xdg.configFile."zoomus.conf".text = ''
      #   [General]
      #   enableWaylandShare=true
      #   autoPlayGif=false
      #   autoScale=true
      #   bForceMaximizeWM=false
      #   captureHDCamera=true
      #   enable.host.auto.grab=true
      #   enableAlwaysShowVideoPreviewDialog=true
      #   enableCloudSwitch=false
      #   enableLogByDefault=false
      #   enableMiniWindow=true
      #   enableShowUserName=false
      #   enableStartMeetingWithRNoise=false
      #   enableTestMode=false
      #   enableWaylandShare=true
      #   playSoundForNewMessage=false
      #   scaleFactor=1
      #   shareBarTopMargin=0
      #   showSystemTitlebar=false
      #   system.audio.type=pulse
      #   useSystemTheme=true
      # '';
    };
  };
}
