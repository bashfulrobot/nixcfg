{
  user-settings,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.sys.xdg;
in
{

  options = {
    sys.xdg.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable xdg.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ unstable.xdg-utils ];
    # Enable xdg
    xdg = {
      mime.enable = true;
      autostart.enable = true;
      icons.enable = true;
      menus.enable = true;
      sounds.enable = true;
    };

    home-manager.users."${user-settings.user.username}" = {
      xdg = {
        # Force overwrite to prevent app conflicts
        configFile."mimeapps.list".force = true;

        # desktopEntries.librewolf = {
        #   name = "LibreWolf";
        #   exec = "${pkgs.librewolf}/bin/librewolf";
        # };
        mimeApps = {
          associations = {
            # added = { "x-scheme-handler/tg" = "org.telegram.desktop.desktop"; };
          };
          enable = true;
          defaultApplications = {
            "text/html" = [ "firefox.desktop" ];
            "text/plain" = [ "code.desktop" ];
            "text/markdown" = [ "code.desktop" ];
            "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
            "application/pdf" = [ "okular.desktop" ];
            "applications/x-www-browser" = [ "firefox.desktop" ];
            "x-scheme-handler/about" = [ "firefox.desktop" ];
            "x-scheme-handler/http" = [ "firefox.desktop" ];
            "x-scheme-handler/https" = [ "firefox.desktop" ];
            "x-scheme-handler/mailto" = [ "firefox.desktop" ];
            "x-scheme-handler/msteams" = [ "teams-for-linux.desktop" ];
            "x-scheme-handler/postman" = [ "Postman.desktop" ];
            # "x-scheme-handler/unknown" = [ "firefox.desktop" ];
            "x-scheme-handler/slack" = [ "slack.desktop" ];
            # "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
            "x-scheme-handler/webcal" = [ "firefox.desktop" ];
            "x-scheme-handler/terminal" = [ "blackbox.desktop" ];
            # Image files
            "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
            "image/png" = [ "org.gnome.Loupe.desktop" ];
            "image/gif" = [ "org.gnome.Loupe.desktop" ];
            "image/webp" = [ "org.gnome.Loupe.desktop" ];
            "image/svg+xml" = [ "org.gnome.Loupe.desktop" ];
            # Audio files
            "audio/mpeg" = [ "vlc.desktop" ];
            "audio/wav" = [ "vlc.desktop" ];
            "audio/flac" = [ "vlc.desktop" ];
            "audio/ogg" = [ "vlc.desktop" ];
            "audio/mp4" = [ "vlc.desktop" ];
            # Video files
            "video/mp4" = [ "vlc.desktop" ];
            "video/x-matroska" = [ "vlc.desktop" ];
            "video/webm" = [ "vlc.desktop" ];
            "video/quicktime" = [ "vlc.desktop" ];
            "video/x-msvideo" = [ "vlc.desktop" ];
            # Archive files
            "application/zip" = [ "org.gnome.FileRoller.desktop" ];
            "application/vnd.rar" = [ "org.gnome.FileRoller.desktop" ];
            "application/x-7z-compressed" = [ "org.gnome.FileRoller.desktop" ];
            "application/gzip" = [ "org.gnome.FileRoller.desktop" ];
            "application/x-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
            "application/x-tar" = [ "org.gnome.FileRoller.desktop" ];
          };
        };
      };
    };
  };
}
