{ config, pkgs, lib, ... }:
# 1Password user configuration with browser integration and package installation

{
    # Install 1Password packages via home-manager for proper desktop integration
    home.packages = with pkgs; [
      _1password-gui  # Desktop app with proper .desktop files
      _1password      # CLI (op command)
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
}