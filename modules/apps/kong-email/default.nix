{ user-settings, config, pkgs, lib, makeDesktopItem, ... }:

let
  cfg = config.apps.kong-email;

  # Import the makeDesktopApp function
  makeDesktopApp = pkgs.callPackage ../../../lib/cbb-webwrap { };

  kongEmailApp = makeDesktopApp {
    name = "Kong Mail";
    url = "https://mail.google.com/mail/u/1/";
    binary = "${pkgs.unstable.chromium}/bin/chromium";
    iconPath = ./icons;
    useAppFlag = true;
  };

in {

  options = {
    apps.kong-email.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Kong Email app.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ kongEmailApp.desktopItem ]
      ++ kongEmailApp.icons;

  };

}