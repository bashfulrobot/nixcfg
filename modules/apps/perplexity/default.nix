# https://raw.githubusercontent.com/Gako358/dotfiles/6236f706279d2450606dfc99fecce9399936b7e7/home/programs/browser/teams.nix
{ user-settings, config, pkgs, lib, makeDesktopItem, ... }:

let
  cfg = config.apps.perplexity;

  # Import the makeDesktopApp function
  makeDesktopApp = pkgs.callPackage ../../../lib/cbb-webwrap { };

  # I temp create an app in brave to download all the icons, then I place then in the correct folder
  perplexityApp = makeDesktopApp {
    name = "Perplexity";
    url = "https://perplexity.ai";
    binary = "${pkgs.chromium}/bin/chromium";
    # myStartupWMClass = "chrome-perplexity.ai__-Default";
    myStartupWMClass = "chromium-browser";
    iconSizes = [ "16" "32" "48" "64" "96" "128" "256" ];
    # iconSizes = [ "256" ]; # forcing large icon use
    iconPath = ./icons; # path to icons
    # Open In Browser vs Open as App
    useAppFlag = false;
  };

in {

  options = {
    apps.perplexity.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the perplexity app.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ perplexityApp.desktopItem ]
      ++ perplexityApp.icons;

    # home-manager.users."${user-settings.user.username}" = {

    # };
  };

}
