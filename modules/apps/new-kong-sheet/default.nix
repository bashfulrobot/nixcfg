# New Kong Sheet - Google Sheets quick create
{ user-settings, config, pkgs, lib, makeDesktopItem, ... }:

let
  cfg = config.apps.new-kong-sheet;

  # Import the makeDesktopApp function
  makeDesktopApp = pkgs.callPackage ../../../lib/cbb-webwrap { };

  newKongSheetApp = makeDesktopApp {
    name = "New Kong Sheet";
    url = "https://sheets.new/2";
    binary = "${pkgs.unstable.brave}/bin/brave";
    myStartupWMClass = "brave-sheets.new__2-Default";
    iconSizes = [ "16" "32" "48" "64" "96" "128" "192" "256" "512" ];
    iconPath = ./icons;
    useAppFlag = true;
  };

in {

  options = {
    apps.new-kong-sheet.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the New Kong Sheet (Google Sheets quick create) app.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ newKongSheetApp.desktopItem ]
      ++ newKongSheetApp.icons;

  };

}