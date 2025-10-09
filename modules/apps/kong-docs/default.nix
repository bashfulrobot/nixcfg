# Kong Developer Documentation web app
{ user-settings, config, pkgs, lib, makeDesktopItem, ... }:

let
  cfg = config.apps.kong-docs;

  # Import the makeDesktopApp function
  makeDesktopApp = pkgs.callPackage ../../../lib/cbb-webwrap { };

  kongDocsApp = makeDesktopApp {
    name = "Kong Docs";
    url = "https://developer.konghq.com/";
    binary = "${pkgs.unstable.chromium}/bin/chromium";
    iconPath = ./icons;
    useAppFlag = true;
  };

in {

  options = {
    apps.kong-docs.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Kong Developer Documentation app.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ kongDocsApp.desktopItem ]
      ++ kongDocsApp.icons;

  };

}