# New Kong Doc - Google Docs quick create
{ user-settings, config, pkgs, lib, makeDesktopItem, ... }:

let
  cfg = config.apps.new-kong-doc;

  # Import the makeDesktopApp function
  makeDesktopApp = pkgs.callPackage ../../../lib/cbb-webwrap { };

  newKongDocApp = makeDesktopApp {
    name = "New Kong Doc";
    url = "https://docs.new/2";
    binary = "${pkgs.google-chrome}/bin/google-chrome-stable";
    myStartupWMClass = "chrome-docs.new__2-Default";
    iconSizes = [ "16" "32" "48" "64" "96" "128" "192" "256" "512" ];
    iconPath = ./icons;
    useAppFlag = true;
  };

in {

  options = {
    apps.new-kong-doc.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the New Kong Doc (Google Docs quick create) app.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ newKongDocApp.desktopItem ]
      ++ newKongDocApp.icons;

  };

}