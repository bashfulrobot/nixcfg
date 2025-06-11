{ user-settings, config, pkgs, lib, makeDesktopItem, ... }:

let
  cfg = config.apps.sysdig-drive;

  # Import the makeDesktopApp function
  makeDesktopApp = pkgs.callPackage ../../../lib/cbb-webwrap { };

  sysdigDriveApp = makeDesktopApp {
    name = "Sysdig Drive";
    url = "https://drive.google.com/drive/u/1/my-drive";
    binary = "${pkgs.chromium}/bin/chromium";
    myStartupWMClass = "chromium-browser";
    iconSizes = [ "32" "48" "64" "96" "128" "256"];
    iconPath = ./icons;
    useAppFlag = true;
  };

in {

  options = {
    apps.sysdig-drive.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Sysdig Drive app.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ sysdigDriveApp.desktopItem ]
      ++ sysdigDriveApp.icons;

  };

}