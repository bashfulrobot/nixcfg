{ user-settings, config, pkgs, lib, makeDesktopItem, ... }:

let
  cfg = config.apps.zoom-web;

  # Import the makeDesktopApp function
  makeDesktopApp = pkgs.callPackage ../../../lib/cbb-webwrap { };

  zoomWebApp = makeDesktopApp {
    name = "Zoom";
    url = "https://app.zoom.us/wc/";
    binary = "${pkgs.unstable.chromium}/bin/chromium";
    iconPath = ./icons; # path to icons
    useAppFlag = true;
    enableLogging = false; # Enable logging for debugging
  };

in {

  options = {
    apps.zoom-web.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Zoom Web Client.";
    };
  };

  config = lib.mkIf cfg.enable {

    # Add zoom web app and URL handler script to system packages
    environment.systemPackages = [ zoomWebApp.desktopItem ]
      ++ zoomWebApp.icons;

    # MIME type associations for Zoom URLs in  a webapp
    apps.zoom-url-handler.enable = true;
  };

}