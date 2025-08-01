{ config, pkgs, lib, ... }:

let
  cfg = config.apps.onepassword;
in {
  options.apps.onepassword = {
    enable = lib.mkEnableOption "Enable 1Password with desktop app, CLI and browser integration";
  };

  config = lib.mkIf cfg.enable {
    # Home Manager configuration (user-level) - Install everything
    home.packages = with pkgs; [
      _1password-gui  # Desktop app
      _1password-cli  # CLI
    ];

    # Browser native messaging integration (always enabled)
    home.file = {
      ".mozilla/native-messaging-hosts/com.1password.1password-firefox.json".source = 
        "${pkgs._1password-gui}/share/1password/resources/custom_allowed_browsers/firefox/com.1password.1password-firefox.json";
      
      ".config/google-chrome/NativeMessagingHosts/com.1password.1password-chrome.json".source = 
        "${pkgs._1password-gui}/share/1password/resources/custom_allowed_browsers/chrome/com.1password.1password-chrome.json";
      
      ".config/chromium/NativeMessagingHosts/com.1password.1password-chrome.json".source = 
        "${pkgs._1password-gui}/share/1password/resources/custom_allowed_browsers/chrome/com.1password.1password-chrome.json";
    };
  };
}