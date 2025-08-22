{
  user-settings,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.apps.firefox;
in
{
  options = {
    apps.firefox = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Firefox browser with single-row layout customizations.";
      };

      enableUserChrome = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable userChrome.css for single-row layout.";
      };

      enableUserContent = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable userContent.css for new tab styling.";
      };

    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${user-settings.user.username}" = {
      # Configure stylix for Firefox theming
      stylix.targets.firefox = {
        profileNames = [ "default" ];
        # Optional: enable additional theming features
        # colorTheme.enable = true;
        # firefoxGnomeTheme.enable = true;
      };
      programs.firefox = {
        enable = true;
        profiles.default = {
          id = 0;
          isDefault = true;
          name = "default";

          userChrome = lib.optionalString cfg.enableUserChrome (builtins.readFile ./userChrome.css);

          userContent = lib.optionalString cfg.enableUserContent (builtins.readFile ./userContent.css);

          settings = {
            # Enable custom CSS loading
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

            # Basic privacy and usability settings - keeping minimal as requested
            # "browser.startup.homepage" = "about:home";
            # "browser.newtabpage.enabled" = true;
          };
        };
      };
    };
  };
}