{ user-settings, config, pkgs, lib, makeDesktopItem, ... }:

let
  cfg = config.apps.konfluence;

  # Import the makeDesktopApp function
  makeDesktopApp = pkgs.callPackage ../../../lib/cbb-webwrap { };

  kongfluenceApp = makeDesktopApp {
    name = "Kongfluence";
    url = "https://konghq.atlassian.net/wiki/spaces/KCX/overview";
    binary = "${pkgs.google-chrome}/bin/google-chrome-stable";
    myStartupWMClass = "google-chrome-konghq.atlassian.net__wiki_spaces_KCX_overview-Default";
    iconSizes = [ "16" "32" "48" "64" "96" "128" "256" ];
    iconPath = ./icons;
    useAppFlag = true;
  };

in {

  options = {
    apps.konfluence.enable = lib.mkOption {
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