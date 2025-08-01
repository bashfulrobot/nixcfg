{ config, pkgs, lib, ... }:

let
  cfg = config.apps.onepassword;
in {
  options.apps.onepassword = {
    enable = lib.mkEnableOption "Enable 1Password with CLI and browser integration";
    
    enableDesktopApp = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install 1Password desktop application";
    };
  };

  config = lib.mkIf cfg.enable {
    # Home Manager configuration (user-level)
    home.packages = with pkgs; [
      (lib.mkIf cfg.enableDesktopApp _1password-gui)
      _1password-cli  # Always install CLI
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