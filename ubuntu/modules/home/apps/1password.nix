{ config, pkgs, lib, ... }:
# 1Password user configuration with browser integration
# Note: Packages are installed system-wide via system-manager module

{
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