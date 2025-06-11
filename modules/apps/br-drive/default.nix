{ user-settings, config, pkgs, lib, makeDesktopItem, ... }:

let
  cfg = config.apps.br-drive;

  # Import the makeDesktopApp function
  makeDesktopApp = pkgs.callPackage ../../../lib/cbb-webwrap { };

  brDriveApp = makeDesktopApp {
    name = "BR Drive";
    url = "https://drive.google.com/drive/u/0/my-drive";
    binary = "${pkgs.chromium}/bin/chromium";
    myStartupWMClass = "chromium-browser";
    iconSizes = [ "32" "48" "64" "96" "128" "256"];
    iconPath = ./icons;
    useAppFlag = true;
  };

in {

  options = {
    apps.br-drive.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the BR Drive app.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ brDriveApp.desktopItem ]
      ++ brDriveApp.icons;

  };

}