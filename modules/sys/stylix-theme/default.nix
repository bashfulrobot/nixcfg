{
  config,
  lib,
  pkgs,
  user-settings,
  ...
}:

let
  cfg = config.sys.stylix-theme;

  # Import custom wallpaper into Nix store if it exists
  wallpaperSetting =
    if (user-settings.theme ? wallpaper) then user-settings.theme.wallpaper else "adwaita-d.jpg";
  customWallpaperPath = "${user-settings.user.home}/Pictures/Wallpapers/${builtins.baseNameOf wallpaperSetting}";

  # Determine wallpaper path: custom wallpapers first, then gnome-backgrounds
  wallpaperPath =
    if builtins.pathExists customWallpaperPath then
      builtins.path {
        path = customWallpaperPath;
        name = builtins.baseNameOf wallpaperSetting;
      }
    else
      "${pkgs.gnome-backgrounds}/share/backgrounds/gnome/${builtins.baseNameOf wallpaperSetting}";

  # Shared stylix configuration values
  stylixAutoEnable = true;
  stylixPolarity = "dark";

  # Font packages and names
  monospacePackage = pkgs.nerd-fonts.jetbrains-mono;
  monospaceName = "JetBrainsMono Nerd Font Mono";
  sansSerifPackage = pkgs.work-sans;
  sansSerifName = "Work Sans";
  serifPackage = pkgs.work-sans;
  serifName = "Work Sans";
  emojiPackage = pkgs.noto-fonts-emoji;
  emojiName = "Noto Color Emoji";

  # Font sizes
  fontSizeApplications = 12;
  fontSizeTerminal = 14;
  fontSizeDesktop = 12;
  fontSizePopups = 12;

  # Cursor configuration
  cursorPackage = pkgs.adwaita-icon-theme;
  cursorName = "Adwaita";
  cursorSize = 24;

  # Qt platform
  qtPlatform = "gnome";
in
{
  options.sys.stylix-theme = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Stylix system-wide theming";
    };
    hm-only = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use home-manager only mode (for Ubuntu/non-NixOS systems)";
    };
  };

  config = lib.mkIf cfg.enable {
    # NixOS system-wide configuration (when hm-only = false)
    stylix = lib.mkIf (!cfg.hm-only) {
      enable = true;
      autoEnable = stylixAutoEnable; # Let stylix auto-detect available applications

      # Extract colors from wallpaper
      image = wallpaperPath;

      # Force dark theme to match desktop
      polarity = stylixPolarity;

      # Font configuration
      fonts = {
        monospace = {
          package = monospacePackage;
          name = monospaceName;
        };
        sansSerif = {
          package = sansSerifPackage;
          name = sansSerifName;
        };
        serif = {
          package = sansSerifPackage;
          name = sansSerifName;
        };
        emoji = {
          package = emojiPackage;
          name = emojiName;
        };
        sizes = {
          applications = fontSizeApplications;
          terminal = fontSizeTerminal;
          desktop = fontSizeDesktop;
          popups = fontSizePopups;
        };
      };

      # Cursor configuration
      cursor = {
        package = cursorPackage;
        name = cursorName;
        size = cursorSize;
      };

      # Qt platform configuration - use gnome for native GNOME integration
      targets.qt.platform = lib.mkForce qtPlatform;
    };

    # Home-manager configuration (when hm-only = true)
    home-manager.users."${user-settings.user.username}" = lib.mkIf cfg.hm-only {
      stylix = {
        enable = true;
        autoEnable = stylixAutoEnable;  # Let stylix auto-detect available applications

        # Extract colors from wallpaper
        image = wallpaperPath;

        # Force dark theme to match desktop
        polarity = stylixPolarity;

        # Font configuration
        fonts = {
          monospace = {
            package = monospacePackage;
            name = monospaceName;
          };
          sansSerif = {
            package = sansSerifPackage;
            name = sansSerifName;
          };
          serif = {
            package = serifPackage;
            name = serifName;
          };
          emoji = {
            package = emojiPackage;
            name = emojiName;
          };
          sizes = {
            applications = fontSizeApplications;
            terminal = fontSizeTerminal;
            desktop = fontSizeDesktop;
            popups = fontSizePopups;
          };
        };

        # Cursor configuration
        cursor = {
          package = cursorPackage;
          name = cursorName;
          size = cursorSize;
        };

        # Qt platform configuration - use gnome for native GNOME integration
        targets.qt.platform = lib.mkForce qtPlatform;
      };

      # Install necessary packages for stylix functionality (home-manager)
      home.packages = with pkgs; [
        imagemagick # For color extraction from images
        base16-schemes # Base16 color schemes (fallback)
      ];
    };
    # Install necessary packages for stylix functionality (NixOS only)
    environment = lib.mkIf (!cfg.hm-only) {
      systemPackages = with pkgs; [
        imagemagick # For color extraction from images
        base16-schemes # Base16 color schemes (fallback)
      ];
    };
  };
}
