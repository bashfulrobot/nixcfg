{ config, pkgs, lib, ... }:

let
  cfg = config.apps.onepassword;
in {
  options.apps.onepassword = {
    enable = lib.mkEnableOption "Enable 1Password with browser integration";
    
    enableDesktopApp = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install 1Password desktop application";
    };
    
    enableCLI = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install 1Password CLI";
    };
    
    enableBrowserIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable native messaging for browser integration";
    };
  };

  config = lib.mkIf cfg.enable {
    # Home Manager configuration (user-level)
    home.packages = with pkgs; [
      (lib.mkIf cfg.enableDesktopApp _1password-gui)
      (lib.mkIf cfg.enableCLI _1password)
    ];

    # Browser native messaging integration
    home.file = lib.mkIf cfg.enableBrowserIntegration {
      ".mozilla/native-messaging-hosts/com.1password.1password-firefox.json".source = 
        "${pkgs._1password-gui}/share/1password/resources/custom_allowed_browsers/firefox/com.1password.1password-firefox.json";
      
      ".config/google-chrome/NativeMessagingHosts/com.1password.1password-chrome.json".source = 
        "${pkgs._1password-gui}/share/1password/resources/custom_allowed_browsers/chrome/com.1password.1password-chrome.json";
      
      ".config/chromium/NativeMessagingHosts/com.1password.1password-chrome.json".source = 
        "${pkgs._1password-gui}/share/1password/resources/custom_allowed_browsers/chrome/com.1password.1password-chrome.json";
    };
  };
}