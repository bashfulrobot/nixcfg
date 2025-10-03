# New Kong Slide - Google Slides quick create
{ user-settings, config, pkgs, lib, makeDesktopItem, ... }:

let
  cfg = config.apps.new-kong-slide;

  # Import the makeDesktopApp function
  makeDesktopApp = pkgs.callPackage ../../../lib/cbb-webwrap { };

  newKongSlideApp = makeDesktopApp {
    name = "New Kong Slide";
    url = "https://slides.new/2";
    binary = "${pkgs.unstable.chromium}/bin/chromium";
    iconSizes = [ "16" "32" "48" "64" "96" "128" "192" "256" "512" ];
    iconPath = ./icons;
    useAppFlag = true;
  };

in {

  options = {
    apps.new-kong-slide.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the New Kong Slide (Google Slides quick create) app.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ newKongSlideApp.desktopItem ]
      ++ newKongSlideApp.icons;

  };

}