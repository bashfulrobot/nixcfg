{ config, lib, pkgs, user-settings, ... }:

let
  cfg = config.sys.stylix-theme;
  
  # Import custom wallpaper into Nix store if it exists
  wallpaperSetting = if (user-settings.theme ? wallpaper) then user-settings.theme.wallpaper else "adwaita-d.jpg";
  customWallpaperPath = "${user-settings.user.home}/Pictures/Wallpapers/${builtins.baseNameOf wallpaperSetting}";
  
  # Determine wallpaper path: custom wallpapers first, then gnome-backgrounds
  wallpaperPath = if builtins.pathExists customWallpaperPath
                  then builtins.path {
                    path = customWallpaperPath;
                    name = builtins.baseNameOf wallpaperSetting;
                  }
                  else "${pkgs.gnome-backgrounds}/share/backgrounds/gnome/${builtins.baseNameOf wallpaperSetting}";
in
{
  options.sys.stylix-theme = {
    enable = lib.mkEnableOption "Stylix system-wide theming";
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

      # Qt platform configuration - use gnome for native GNOME integration
      targets.qt.platform = lib.mkForce "gnome";
    };

    # Install necessary packages for stylix functionality
    environment.systemPackages = with pkgs; [
      imagemagick  # For color extraction from images
      base16-schemes  # Base16 color schemes (fallback)
    ];
  };
}