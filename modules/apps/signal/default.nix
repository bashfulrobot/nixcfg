{ user-settings, pkgs, config, lib, ... }:
let
  cfg = config.apps.signal;

  # Override Signal desktop to add password store flag
  customSignal = pkgs.unstable.signal-desktop.overrideAttrs (oldAttrs: rec {
    desktopItems = map (item: item.override (d: {
      exec = "${pkgs.unstable.signal-desktop}/bin/signal-desktop --password-store=\"gnome-libsecret\" --no-sandbox %U";
    })) oldAttrs.desktopItems;

    installPhase = builtins.replaceStrings
      (map (item: "${item}") oldAttrs.desktopItems)
      (map (item: "${item}") desktopItems)
      oldAttrs.installPhase;
  });

in {

  options = {
    apps.signal = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Signal with custom desktop file override.";
      };
      forceGnomeLibsecret = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Force Signal to use GNOME libsecret for password storage.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Install Signal - either custom or regular based on forceGnomeLibsecret option
    environment.systemPackages = [
      (if cfg.forceGnomeLibsecret then customSignal else pkgs.unstable.signal-desktop)
    ];
  };
}