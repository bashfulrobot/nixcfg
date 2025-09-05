{
  user-settings,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.apps.browsers.google-chrome;
  browserExecutable = "google-chrome-stable";
in
{
  options = {
    apps.browsers.google-chrome = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Google Chrome browser.";
      };

      setAsDefault = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Set Google Chrome as the default browser";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${user-settings.user.username}" = {
      programs.chromium = {
        enable = true;
        package = pkgs.google-chrome;
        # extensions = [
        #   # 1password
        #   "aeblfdkhhhdcdjpifhhbdiojplfjncoa"
        #   # ublock origin
        #   "cjpalhdlnbpafiamejdnhcphjbkeiagm"
        #   # dark reader
        #   "eimadpbcbfnmbkopoojfekhnkhdbieeh"
        # ];
      };

      home.sessionVariables = lib.mkIf cfg.setAsDefault {
        BROWSER = "google-chrome-stable";
      };

      xdg.mimeApps.defaultApplications = lib.mkIf cfg.setAsDefault {
        "text/html" = "google-chrome.desktop";
        "x-scheme-handler/http" = "google-chrome.desktop";
        "x-scheme-handler/https" = "google-chrome.desktop";
        "x-scheme-handler/about" = "google-chrome.desktop";
        "x-scheme-handler/unknown" = "google-chrome.desktop";
        "applications/x-www-browser" = "google-chrome.desktop";
      };
    };
  };
}
