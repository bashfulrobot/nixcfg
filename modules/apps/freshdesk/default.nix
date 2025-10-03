{ user-settings, config, pkgs, lib, makeDesktopItem, ... }:

let
  cfg = config.apps.freshdesk;

  # Import the makeDesktopApp function
  makeDesktopApp = pkgs.callPackage ../../../lib/cbb-webwrap { };

  freshdeskApp = makeDesktopApp {
    name = "Freshdesk";
    url = "https://kong.freshservice.com/support/home";
    binary = "${pkgs.unstable.chromium}/bin/chromium";
    iconSizes = [ "16" "32" "48" "64" "96" "128" "256" ];
    iconPath = ./icons;
    useAppFlag = true;
  };

in {

  options = {
    apps.freshdesk.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Freshdesk app.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ freshdeskApp.desktopItem ]
      ++ freshdeskApp.icons;

  };

}