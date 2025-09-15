# Lucidchart - Diagramming and visualization app
{ user-settings, config, pkgs, lib, makeDesktopItem, ... }:

let
  cfg = config.apps.lucidchart;

  # Import the makeDesktopApp function
  makeDesktopApp = pkgs.callPackage ../../../lib/cbb-webwrap { };

  lucidchartApp = makeDesktopApp {
    name = "Lucidchart";
    url = "https://lucid.app/documents#/home?folder_id=recent";
    binary = "${pkgs.unstable.brave}/bin/brave";
    myStartupWMClass = "brave-lucid.app__documents-Default";
    iconSizes = [ "16" "32" "48" "64" "96" "128" "192" "256" "512" ];
    iconPath = ./icons;
    useAppFlag = true;
  };

in {

  options = {
    apps.lucidchart.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Lucidchart app.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ lucidchartApp.desktopItem ]
      ++ lucidchartApp.icons;

  };

}