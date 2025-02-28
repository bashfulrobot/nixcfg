# https://raw.githubusercontent.com/Gako358/dotfiles/6236f706279d2450606dfc99fecce9399936b7e7/home/programs/browser/teams.nix
{ user-settings, config, pkgs, lib, makeDesktopItem, ... }:

let
  cfg = config.apps.gainsight;

  # Import the makeDesktopApp function
  makeDesktopApp = pkgs.callPackage ../../../lib/cbb-webwrap { };

  # I temp create an app in brave to download all the icons, then I place then in the correct folder
  gainsightApp = makeDesktopApp {
    name = "gainsight";
    url = "https://sysdig.us2.gainsightcloud.com/v1/ui/home#/";
    binary = "${pkgs.chromium}/bin/chromium";
    # myStartupWMClass = "chrome-sysdig.lightning.force.com__lightning_r_Account_001j000000xlClCAAU_view-Default";
    myStartupWMClass = "chromium-browser";

    iconSizes = [ "64" ];
    # iconSizes = [ "256" ]; # forcing large icon use
    iconPath = ./icons; # path to icons
    # Open In Browser vs Open as App
    useAppFlag = false;
  };

in {

  options = {
    apps.gainsight.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the gainsight app.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ gainsightApp.desktopItem ]
      ++ gainsightApp.icons;

    # home-manager.users."${user-settings.user.username}" = {

    # };
  };

}
