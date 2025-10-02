{ user-settings, config, pkgs, lib, makeDesktopItem, ... }:

let
  cfg = config.apps.gemini-pro;

  # Import the makeDesktopApp function
  makeDesktopApp = pkgs.callPackage ../../../lib/cbb-webwrap { };

  geminiProApp = makeDesktopApp {
    name = "Gemini Pro";
    url = "https://gemini.google.com/u/1/app";
    binary = "${pkgs.unstable.chromium}/bin/chromium";
    myStartupWMClass = "chrome-gemini.google.com__u_1_app-Default";
    iconSizes = [ "16" "32" "48" "64" "96" "128" "192" "256" "512" ];
    iconPath = ./icons;
    useAppFlag = true;
  };

in {

  options = {
    apps.gemini-pro.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Gemini Pro app.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ geminiProApp.desktopItem ]
      ++ geminiProApp.icons;

  };

}