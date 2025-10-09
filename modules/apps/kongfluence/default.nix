{ user-settings, config, pkgs, lib, makeDesktopItem, ... }:

let
  cfg = config.apps.kongfluence;

  # Import the makeDesktopApp function
  makeDesktopApp = pkgs.callPackage ../../../lib/cbb-webwrap { };

  kongfluenceApp = makeDesktopApp {
    name = "Kongfluence";
    url = "https://konghq.atlassian.net/wiki/spaces/KCX/overview";
    binary = "${pkgs.unstable.chromium}/bin/chromium";
    iconPath = ./icons;
    useAppFlag = true;
    enableLogging = false;
  };

in {

  options = {
    apps.kongfluence.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Kong Confluence app.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ kongfluenceApp.desktopItem ]
      ++ kongfluenceApp.icons;

  };

}