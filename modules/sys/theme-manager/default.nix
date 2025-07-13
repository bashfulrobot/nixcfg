{ config, lib, pkgs, user-settings, ... }:

let
  cfg = config.sys.theme-manager;
  themeName = user-settings.theme.name or "catppuccin";
  themeVariant = user-settings.theme.variant or "mocha";
  
  # Dynamic rofi color import based on theme
  rofiThemeImport = if themeName == "adwaita" 
                   then "~/.config/rofi/colors/adwaita.rasi"
                   else if themeName == "dracula"
                   then "~/.config/rofi/colors/dracula.rasi"
                   else "~/.config/rofi/colors/catppuccin.rasi";
in
{
  options.sys.theme-manager = {
    enable = lib.mkEnableOption "centralized theme management";
  };

  config = lib.mkIf cfg.enable {
    # Enable the appropriate theme based on settings
    sys.catppuccin-theme.enable = lib.mkIf (themeName == "catppuccin") true;
    sys.adwaita-theme.enable = lib.mkIf (themeName == "adwaita") true;
    sys.dracula-theme.enable = lib.mkIf (themeName == "dracula") true;

    # Ensure only one theme is active at a time
    assertions = [
      {
        assertion = !(config.sys.catppuccin-theme.enable && config.sys.adwaita-theme.enable && config.sys.dracula-theme.enable) &&
                   (lib.length (lib.filter (x: x) [config.sys.catppuccin-theme.enable config.sys.adwaita-theme.enable config.sys.dracula-theme.enable]) <= 1);
        message = "Only one theme can be enabled at a time. Check your theme settings.";
      }
    ];

    # Provide theme information to other modules
    environment.sessionVariables = {
      CURRENT_THEME = themeName;
      CURRENT_THEME_VARIANT = themeVariant;
    };

    # Dynamic rofi theme configuration
    home-manager.users."${user-settings.user.username}" = {
      xdg.configFile = {
        # Override rofi color imports to use dynamic theme
        "rofi/launchers/type-1/shared/colors.rasi".text = ''
          /**
           * Dynamic theme configuration
           * Managed by NixOS theme-manager
           */
          
          @import "${rofiThemeImport}"
        '';
        
        "rofi/launchers/type-2/shared/colors.rasi".text = ''
          @import "${rofiThemeImport}"
        '';
        
        "rofi/launchers/type-3/shared/colors.rasi".text = ''
          @import "${rofiThemeImport}"
        '';
        
        "rofi/launchers/type-4/shared/colors.rasi".text = ''
          @import "${rofiThemeImport}"
        '';
      };
    };
  };
}