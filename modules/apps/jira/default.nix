# https://raw.githubusercontent.com/Gako358/dotfiles/6236f706279d2450606dfc99fecce9399936b7e7/home/programs/browser/teams.nix
{ user-settings, config, pkgs, lib, makeDesktopItem, ... }:

let
  cfg = config.apps.jira;

  # Import the makeDesktopApp function
  makeDesktopApp = pkgs.callPackage ../../../lib/cbb-webwrap { };

  jiraKongApp = makeDesktopApp {
    name = "Jira";
    url = "https://konghq.atlassian.net/jira/for-you";
    binary = "${pkgs.unstable.chromium}/bin/chromium";
    iconPath = ./icons; # path to icons
    # Open In Browser vs Open as App
    useAppFlag = true;
  };

in {

  options = {
    apps.jira.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Kong jira app.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ jiraKongApp.desktopItem ]
      ++ jiraKongApp.icons;

    # home-manager.users."${user-settings.user.username}" = {

    # };
  };

}
