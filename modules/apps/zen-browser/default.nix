{ config, lib, pkgs, user-settings, zen-browser, ... }:

let
  cfg = config.apps.zen-browser;
  
  # Theme color mappings based on system theme
  themeColors = {
    dracula = {
      accent = "#bd93f9";
      background = "#282a36";
    };
    catppuccin = {
      accent = "#89b4fa";
      background = "#1e1e2e";
    };
    adwaita = {
      accent = "#78aeed";
      background = "#1e1e1e";
    };
  };
  
  currentTheme = user-settings.theme.name or "dracula";
  accentColor = themeColors.${currentTheme}.accent or "#bd93f9";
in
{
  options.apps.zen-browser = {
    enable = lib.mkEnableOption "Zen Browser";
    
    setAsDefault = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Set Zen Browser as the default browser";
    };
  };

  config = lib.mkIf cfg.enable {
    # Install Zen Browser
    environment.systemPackages = [
      zen-browser.packages.${pkgs.system}.default
    ];

    # Configure 1Password integration
    environment.etc."1password/custom_allowed_browsers".text = lib.mkAfter ''
      zen
    '';

    # Home-manager configuration
    home-manager.users."${user-settings.user.username}" = {
      home.sessionVariables = lib.mkIf cfg.setAsDefault {
        BROWSER = "zen";
      };

      xdg.mimeApps.defaultApplications = lib.mkIf cfg.setAsDefault {
        "text/html" = "zen.desktop";
        "x-scheme-handler/http" = "zen.desktop";
        "x-scheme-handler/https" = "zen.desktop";
        "x-scheme-handler/about" = "zen.desktop";
        "x-scheme-handler/unknown" = "zen.desktop";
      };

      # Configure Zen Browser to use Wayland
      home.file.".config/zen-flags.conf".text = ''
        --enable-features=UseOzonePlatform
        --ozone-platform=wayland
        --enable-features=WaylandWindowDecorations
        --ozone-platform-hint=auto
        --gtk-version=4
      '';

      # Configure Zen Browser theme integration
      home.file.".zen/user.js".text = ''
        // System theme integration
        user_pref("zen.theme.accent-color", "${accentColor}");
        user_pref("zen.theme.gradient", true);
        user_pref("zen.theme.gradient.show-custom-colors", true);
        user_pref("zen.view.gray-out-inactive-windows", true);
        user_pref("zen.theme.essentials-favicon-bg", true);
        
        // Dark theme preference to match system
        user_pref("ui.systemUsesDarkTheme", 1);
        user_pref("browser.theme.content-theme", 0);
        user_pref("browser.theme.toolbar-theme", 0);
      '';
    };
  };
}