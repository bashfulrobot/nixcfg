{ user-settings, config, pkgs, lib, makeDesktopItem, ... }:

let
  cfg = config.apps.kong-calendar;

  # Import the makeDesktopApp function
  makeDesktopApp = pkgs.callPackage ../../../lib/cbb-webwrap { };

  kongCalendarApp = makeDesktopApp {
    name = "Kong Calendar";
    url = "https://calendar.google.com/calendar/u/1/r";
    binary = "${pkgs.unstable.chromium}/bin/chromium";
    myStartupWMClass = "chrome-calendar.google.com__calendar_u_1_r-Default";
    iconSizes = [ "32" "48" "64" "96" "128" "192" "256" "512" ];
    iconPath = ./icons;
    useAppFlag = true;
  };

in {

  options = {
    apps.kong-calendar.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Kong Calendar app.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ kongCalendarApp.desktopItem ]
      ++ kongCalendarApp.icons;

  };

}