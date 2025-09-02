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
        # Context.sockets = [ "wayland" "fallback-x11" "pulseaudio" ];
        # Context.devices = [ "dri" ];
        # Context.features = [ "devel" ];
        # Context.filesystems = [
        #   "xdg-documents"
        #   "xdg-pictures"
        #   "xdg-videos"
        #   "xdg-desktop"
        #   "xdg-download"
        # ];
        # Context.shared = [ "network" "ipc" ];
        # Context.talks = [
        #   "org.freedesktop.Notifications"
        #   "org.freedesktop.ScreenSaver"
        #   "org.freedesktop.PowerManagement.Inhibit"
        #   "org.freedesktop.portal.Desktop"
        #   "org.freedesktop.portal.Screenshot"
        #   "org.freedesktop.portal.ScreenCast"
        # ];
        # Context.owns = [
        #   "org.gnome.*"
        # ];
        Environment = {
          XDG_CURRENT_DESKTOP = "gnome";
        };
      };
    };

    home-manager.users."${user-settings.user.username}" = {
      xdg.mimeApps.defaultApplications = {
        "x-scheme-handler/zoom" = "us.zoom.Zoom.desktop";
        "x-scheme-handler/zoommtg" = "us.zoom.Zoom.desktop";
        "x-scheme-handler/zoomus" = "us.zoom.Zoom.desktop";
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
