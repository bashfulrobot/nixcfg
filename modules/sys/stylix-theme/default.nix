{ config, lib, pkgs, user-settings, ... }:

let
  cfg = config.sys.stylix-theme;
  wallpaperPath = config.sys.wallpapers.getWallpaper cfg.wallpaperType;
in
{
  options.sys.stylix-theme = {
    enable = lib.mkEnableOption "Stylix system-wide theming";
    useWallpaper = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to extract colors from wallpaper (true) or use handmade scheme (false)";
    };
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
      
      # Force dark theme to match desktop
      polarity = "dark";
      
      # Font configuration
      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font Mono";
        };
        sansSerif = {
          package = pkgs.nerd-fonts.liberation;
          name = "LiterationSans Nerd Font";
        };
        serif = {
          package = pkgs.nerd-fonts.liberation;
          name = "LiterationSerif Nerd Font";
        };
        # Previous fonts (fallback):
        # monospace = {
        #   package = pkgs.nerd-fonts.jetbrains-mono;
        #   name = "JetBrainsMono Nerd Font Mono";
        # };
        # sansSerif = {
        #   package = pkgs.work-sans;
        #   name = "Work Sans";
        # };
        # serif = {
        #   package = pkgs.work-sans;
        #   name = "Work Sans";
        # };
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

      # Qt platform configuration - use gnome for native GNOME integration
      targets.qt.platform = lib.mkForce "gnome";
      
      # Disable Plymouth targeting to avoid missing theme files
      targets.plymouth.enable = lib.mkForce false;
    } // (if cfg.useWallpaper then {
      # Extract colors from wallpaper
      image = wallpaperPath;
    } else {
      # Use handmade base16 scheme but still set wallpaper
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${user-settings.theme.handmade-scheme}.yaml";
      image = wallpaperPath;
    });

    # Install necessary packages for stylix functionality
    environment.systemPackages = with pkgs; [
      unstable.imagemagickBig  # For color extraction from images
      base16-schemes  # Base16 color schemes (fallback)
    ];
  };
}