# https://raw.githubusercontent.com/Gako358/dotfiles/6236f706279d2450606dfc99fecce9399936b7e7/home/programs/browser/teams.nix
{ user-settings, config, pkgs, lib, makeDesktopItem, ... }:

let
  cfg = config.cli.xkill;

  # Import the makeDesktopFile function
  makeDesktopFile = pkgs.callPackage ../../../lib/mk-desktop { };


  xkillDesktopFile = makeDesktopFile {
    name = "xkill";
    binary = "${pkgs.xorg.xkill}/bin/xkill";
    myStartupWMClass = "";
    iconSizes = ["64"];
    iconPath = ./icons; # path to icons
  };

in {

  options = {
    cli.xkill.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Add xkill Desktop File.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ xkillDesktopFile.desktopItem ]
      ++ xkillDesktopFile.icons;

    # home-manager.users."${user-settings.user.username}" = {

    # };
  };

}
