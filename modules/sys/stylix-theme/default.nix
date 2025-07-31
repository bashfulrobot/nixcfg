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
    hm-only = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use home-manager only mode (for Ubuntu/non-NixOS systems)";
    };
  };

  config = lib.mkIf cfg.enable (
    let
      # Shared stylix configuration variables
      stylixFonts = {
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

      stylixCursor = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
      };

      stylixPackages = with pkgs; [
        imagemagick  # For color extraction from images
        base16-schemes  # Base16 color schemes (fallback)
      ];
    in
    (lib.mkMerge [
      # NixOS system-level configuration (only when not hm-only)
      (lib.mkIf (!cfg.hm-only) {
        stylix = {
          enable = true;
          autoEnable = true;
          image = wallpaperPath;
          polarity = "dark";
          fonts = stylixFonts;
          cursor = stylixCursor;
          targets.qt.platform = lib.mkForce "gnome";
        };
        
        environment.systemPackages = stylixPackages;
      })
      
      # Home-manager configuration (always present)
      {
        home-manager.users."${user-settings.user.username}" = {
          stylix = {
            enable = true;
            autoEnable = true;
            image = wallpaperPath;
            polarity = "dark";
            fonts = stylixFonts;
            cursor = stylixCursor;
            targets.qt.platform = lib.mkForce "gnome";
          };
          home.packages = lib.mkIf cfg.hm-only stylixPackages;
        };
      }
    ])
  );
}