{ user-settings, pkgs, config, lib, ... }:
let 
  cfg = config.apps.signal;
  
  # Create a custom Signal desktop item with the password store flag
  signalDesktopItem = pkgs.makeDesktopItem {
    name = "signal-desktop";
    desktopName = "Signal";
    comment = "Private messaging from your desktop";
    exec = "${pkgs.unstable.signal-desktop}/bin/signal-desktop --password-store=\"gnome-libsecret\" --no-sandbox %U";
    icon = "signal-desktop";
    type = "Application";
    startupNotify = true;
    categories = [ "Network" "InstantMessaging" ];
    mimeTypes = [ "x-scheme-handler/sgnl" "x-scheme-handler/signalcaptcha" ];
    startupWMClass = "Signal";
  };

in {

  options = {
    apps.signal = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Signal with custom desktop file override.";
      };
    };
  };

  config = lib.mkIf cfg.enable {

    # Install only the custom desktop file (it references the Signal binary)
    environment.systemPackages = with pkgs; [
      unstable.signal-desktop
      signalDesktopItem
    ];

    # Override the original desktop file to prevent duplicates
    environment.etc."share/applications/signal-desktop.desktop".source = lib.mkForce "${signalDesktopItem}/share/applications/signal-desktop.desktop";
  };
}