{
  user-settings,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.apps.browsers.firefox;
in
{
  options = {
    apps.browsers.firefox = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Firefox browser with single-row layout customizations.";
      };

      setAsDefault = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Set Firefox as the default browser";
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
    # Configure Zoom Flatpak to use this browser when set as default
    services.flatpak.overrides."us.zoom.Zoom".Environment.BROWSER = lib.mkIf cfg.setAsDefault "firefox";

    home-manager.users."${user-settings.user.username}" = {
      # Enable backups for conflicting files
      home = {
        enableNixpkgsReleaseCheck = false;
        file.".mozilla/firefox/profiles.ini".force = true;
        sessionVariables = lib.mkIf cfg.setAsDefault {
          BROWSER = "firefox";
        };
      };
      # Configure stylix for Firefox theming
      stylix.targets.firefox = {
        profileNames = [ "default" ];
        # Optional: enable additional theming features
        # colorTheme.enable = true;
        # firefoxGnomeTheme.enable = true;
      };

      programs.firefox = {
        enable = true;
        package = pkgs.unstable.firefox;
        profiles.default = {
          id = 0;
          isDefault = true;
          name = "default";

          userChrome = lib.optionalString cfg.enableUserChrome (builtins.readFile ./userChrome.css);

          userContent = lib.optionalString cfg.enableUserContent (builtins.readFile ./userContent.css);

          settings = {
            # Enable custom CSS loading
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

            # Enable vertical tabs (newer Firefox feature)
            "sidebar.verticalTabs" = true;
            "sidebar.revamp" = true;

            # Enable sidebar expand on hover
            #"sidebar.visibility" = "always-show";
            #"sidebar.main.tools" = "history";

            # Sidebar animation settings
            "sidebar.animation.duration-ms" = 200;

            # Basic privacy and usability settings - keeping minimal as requested
            # "browser.startup.homepage" = "about:home";
            # "browser.newtabpage.enabled" = true;
          };
        };
      };

      xdg.mimeApps = lib.mkIf cfg.setAsDefault {
        enable = true;
        defaultApplications = {
          "text/html" = [ "firefox.desktop" ];
          "x-scheme-handler/http" = [ "firefox.desktop" ];
          "x-scheme-handler/https" = [ "firefox.desktop" ];
          "x-scheme-handler/about" = [ "firefox.desktop" ];
          "x-scheme-handler/unknown" = [ "firefox.desktop" ];
          "x-scheme-handler/mailto" = [ "firefox.desktop" ];
          "x-scheme-handler/webcal" = [ "firefox.desktop" ];
          "applications/x-www-browser" = [ "firefox.desktop" ];
        };
      };
    };
  };
}
