{ user-settings, config, pkgs, lib, makeDesktopItem, ... }:

let
  cfg = config.apps.kong-drive;

  # Import the makeDesktopApp function
  makeDesktopApp = pkgs.callPackage ../../../lib/cbb-webwrap { };

  kongDriveApp = makeDesktopApp {
    name = "Kong Drive";
    url = "https://drive.google.com/drive/u/1/my-drive";
    binary = "${pkgs.google-chrome}/bin/google-chrome-stable";
    myStartupWMClass = "google-chrome-drive.google.com__drive_u_1_my-drive-Default";
    iconSizes = [ "32" "48" "64" "96" "128" "256"];
    iconPath = ./icons;
    useAppFlag = true;
  };

in {

  options = {
    apps.kong-drive.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Kong Drive app.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ kongDriveApp.desktopItem ]
      ++ kongDriveApp.icons;

  };

}