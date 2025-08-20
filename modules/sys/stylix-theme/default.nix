{ config, lib, pkgs, user-settings, ... }:

let
  cfg = config.sys.stylix-theme;
  wallpaperPath = config.sys.wallpapers.getWallpaper cfg.wallpaperType;
in
{
  options.sys.stylix-theme = {
    enable = lib.mkEnableOption "Stylix system-wide theming";
    wallpaperType = lib.mkOption {
      type = lib.types.enum [ "personal" "professional" ];
      default = "personal";
      description = "Which wallpaper type to use: personal or professional";
    };
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      autoEnable = true;  # Let stylix auto-detect available applications
      
      # Extract colors from wallpaper
      image = wallpaperPath;
      
      # Force dark theme to match desktop
      polarity = "dark";
      
      # Font configuration
      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font Mono";
        };
        sansSerif = {
          package = pkgs.work-sans;
          name = "Work Sans";
        };
        serif = {
          package = pkgs.work-sans;
          name = "Work Sans";
        };
        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
        sizes = {
          applications = 12;
          terminal = 14;
          desktop = 12;
          popups = 12;
        };
      };

      # Cursor configuration
      cursor = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
      };

      # Qt platform configuration - use qtct (only supported option by stylix)
      targets.qt.platform = lib.mkForce "qtct";
      
      # Disable Plymouth targeting to avoid missing theme files
      targets.plymouth.enable = lib.mkForce false;
    };

    # Install necessary packages for stylix functionality
    environment.systemPackages = with pkgs; [
      imagemagick  # For color extraction from images
      base16-schemes  # Base16 color schemes (fallback)
    ];
  };
}