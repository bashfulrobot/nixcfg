{ user-settings, config, pkgs, lib, makeDesktopItem, ... }:

let
  cfg = config.apps.kong-email;

  # Import the makeDesktopApp function
  makeDesktopApp = pkgs.callPackage ../../../lib/cbb-webwrap { };

  kongEmailApp = makeDesktopApp {
    name = "Kong Mail";
    url = "https://mail.google.com/mail/u/1/#search/is%3Aunread+in%3Ainbox";
    binary = "${pkgs.google-chrome}/bin/google-chrome-stable";
    myStartupWMClass = "chrome-mail.google.com__mail_u_1_-Default";
    iconSizes = [ "32" "48" "64" "96" "128" "192" "256" "512" ];
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