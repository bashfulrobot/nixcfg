{
  user-settings,
  config,
  lib,
  ...
}:
let
  wallpaperPath = "${user-settings.user.home}/Pictures/wallpapers/${user-settings.theme.personal-wallpaper}";
in
{
  # COSMIC Appearance and Theme Configuration
  home-manager.users."${user-settings.user.username}" = {
    xdg.configFile = {
      # Wallpaper configuration for COSMIC Settings
      "cosmic/com.system76.CosmicSettings.Wallpaper/v1/custom-images".text = wallpaperPath;

      # Theme mode configuration
      "cosmic/com.system76.CosmicTheme.Mode/v1/is_dark".text = ''
        true
      '';

      # Dark theme color configurations
      "cosmic/com.system76.CosmicTheme.Dark.Builder/v1/accent".text = ''
        (srgb: (red: 0.458824, green: 0.678431, blue: 0.498039, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/accent".text = ''
        (srgb: (red: 0.458824, green: 0.678431, blue: 0.498039, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/accent_button".text = ''
        (srgb: (red: 0.458824, green: 0.678431, blue: 0.498039, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/background".text = ''
        (srgb: (red: 0.156863, green: 0.156863, blue: 0.156863, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/button".text = ''
        (srgb: (red: 0.235294, green: 0.235294, blue: 0.235294, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/destructive".text = ''
        (srgb: (red: 0.8, green: 0.141176, blue: 0.141176, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/destructive_button".text = ''
        (srgb: (red: 0.8, green: 0.141176, blue: 0.141176, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/link_button".text = ''
        (srgb: (red: 0.458824, green: 0.678431, blue: 0.498039, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/icon_button".text = ''
        (srgb: (red: 0.458824, green: 0.678431, blue: 0.498039, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/primary".text = ''
        (srgb: (red: 0.921569, green: 0.858824, blue: 0.698039, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/secondary".text = ''
        (srgb: (red: 0.658824, green: 0.600000, blue: 0.498039, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/success".text = ''
        (srgb: (red: 0.458824, green: 0.678431, blue: 0.498039, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/text_button".text = ''
        (srgb: (red: 0.921569, green: 0.858824, blue: 0.698039, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/warning".text = ''
        (srgb: (red: 0.980392, green: 0.721569, blue: 0.423529, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/warning_button".text = ''
        (srgb: (red: 0.980392, green: 0.721569, blue: 0.423529, alpha: 1.0))
      '';

      # COSMIC Toolkit interface configurations
      "cosmic/com.system76.CosmicTk/v1/interface_density".text = ''
        Spacious
      '';

      "cosmic/com.system76.CosmicTk/v1/header_size".text = ''
        Spacious
      '';

      "cosmic/com.system76.CosmicTk/v1/interface_font".text = ''
        (
            family: "Noto Sans",
            weight: Normal,
            stretch: Normal,
            style: Normal,
        )
      '';

      "cosmic/com.system76.CosmicTk/v1/monospace_font".text = ''
        (
            family: "JetBrainsMonoNL Nerd Font Mono",
            weight: Normal,
            stretch: Normal,
            style: Normal,
        )
      '';

      # COSMIC Dark Theme spacing and layout configurations
      "cosmic/com.system76.CosmicTheme.Dark/v1/spacing".text = ''
        (
            space_none: 4,
            space_xxxs: 8,
            space_xxs: 12,
            space_xs: 16,
            space_s: 24,
            space_m: 32,
            space_l: 48,
            space_xl: 64,
            space_xxl: 128,
            space_xxxl: 160,
        )
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/gaps".text = ''
        (0, 15)
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/active_hint".text = ''
        1
      '';

      # COSMIC Dark Theme corner radii configuration
      "cosmic/com.system76.CosmicTheme.Dark/v1/corner_radii".text = ''
        (
            radius_0: (0.0, 0.0, 0.0, 0.0),
            radius_xs: (2.0, 2.0, 2.0, 2.0),
            radius_s: (8.0, 8.0, 8.0, 8.0),
            radius_m: (8.0, 8.0, 8.0, 8.0),
            radius_l: (8.0, 8.0, 8.0, 8.0),
            radius_xl: (8.0, 8.0, 8.0, 8.0),
        )
      '';
    };
  };
}