# https://raw.githubusercontent.com/Gako358/dotfiles/6236f706279d2450606dfc99fecce9399936b7e7/home/programs/browser/teams.nix
{ user-settings, config, pkgs, lib, makeDesktopItem, ... }:

let
  cfg = config.apps.sfdc;

  # Import the makeDesktopApp function
  makeDesktopApp = pkgs.callPackage ../../../lib/cbb-webwrap { };

  # I temp create an app in brave to download all the icons, then I place then in the correct folder
  sfdcApp = makeDesktopApp {
    name = "Sfdc";
    url = "https://kong.lightning.force.com/lightning/r/Dashboard/01ZPJ000004TcSb2AK/view?queryScope=userFolders";
    binary = "${pkgs.google-chrome}/bin/google-chrome-stable";
    # myStartupWMClass = "chrome-sysdig.lightning.force.com__lightning_r_Account_001j000000xlClCAAU_view-Default";
    myStartupWMClass = "chrome-kong.lightning.force.com__lightning_r_Dashboard_01ZPJ000004TcSb2AK_view-Default";

    iconSizes = [ "16" "32" "48" "64" "96" "128" "180" "256" ];
    # iconSizes = [ "256" ]; # forcing large icon use
    iconPath = ./icons; # path to icons
    # Open In Browser vs Open as App
    useAppFlag = true;
  };

in {

  options = {
    apps.sfdc.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the SFDC app.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ sfdcApp.desktopItem ]
      ++ sfdcApp.icons;

    # home-manager.users."${user-settings.user.username}" = {

    # };
  };

}
