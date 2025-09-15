# Avanti - AI-powered letter writing assistant
{ user-settings, config, pkgs, lib, makeDesktopItem, ... }:

let
  cfg = config.apps.avanti;

  # Import the makeDesktopApp function
  makeDesktopApp = pkgs.callPackage ../../../lib/cbb-webwrap { };

  avantiApp = makeDesktopApp {
    name = "Avanti";
    url = "https://avanti.letter.ai/?scope=all";
    binary = "${pkgs.unstable.brave}/bin/brave";
    myStartupWMClass = "brave-avanti.letter.ai__-Default";
    iconSizes = [ "16" "32" "48" "64" "96" "128" "192" "256" "512" ];
    iconPath = ./icons;
    useAppFlag = true;
  };

in {

  options = {
    apps.avanti.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Avanti app.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ avantiApp.desktopItem ]
      ++ avantiApp.icons;

  };

}