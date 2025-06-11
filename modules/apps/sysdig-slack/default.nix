# Sysdig Slack web app wrapper
{
  user-settings,
  config,
  pkgs,
  lib,
  makeDesktopItem,
  ...
}:

let
  cfg = config.apps.slack;

  # Import the makeDesktopApp function
  makeDesktopApp = pkgs.callPackage ../../../lib/cbb-webwrap { };

  # Sysdig Slack app wrapper
  slackApp = makeDesktopApp {
    name = "Slack";
    url = "https://sysdigcloud.slack.com";
    binary = "${pkgs.chromium}/bin/chromium";
    myStartupWMClass = "chrome-sysdigcloud.slack.com__-Default";
    iconSizes = [
      "32"
      "48"
      "64"
      "96"
      "128"
      "256"
    ];
    iconPath = ./icons; # path to slack icons
    # Open In Browser vs Open as App
    useAppFlag = true;
  };

in
{

  options = {
    apps.slack.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Slack app.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ slackApp.desktopItem ] ++ slackApp.icons;

  };

}
