{
  user-settings,
  config,
  lib,
  ...
}:
let
  wallpaperPath = config.sys.wallpapers.getWallpaper "professional";

  # Import theme generation functions from separate module
  themeGen = import ./theme-gen.nix { inherit config lib; };
  inherit (themeGen.cosmicThemes) generateDarkTheme generateLightTheme;

in
{
  # COSMIC Appearance and Theme Configuration
  home-manager.users."${user-settings.user.username}" = {
    xdg.configFile = {
      # Add wallpaper to custom images list (JSON array format)
      "cosmic/com.system76.CosmicSettings.Wallpaper/v1/custom-images".text = ''
        [
            "${wallpaperPath}",
        ]
      '';

      # Set the actual wallpaper background
      "cosmic/com.system76.CosmicBackground/v1/all" = {
        text = ''
          (
              output: "all",
              source: Path("${wallpaperPath}"),
              filter_by_theme: true,
              rotation_frequency: 300,
              filter_method: Lanczos,
              scaling_mode: Zoom,
              sampling_method: Alphanumeric,
          )
        '';
        force = true;
      };

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
    };

    # Stylix theme integration - generate COSMIC themes from stylix colors for build script
    home.file = lib.mkIf config.stylix.enable {
      # Create generated theme files for the build script to use
      "dev/nix/nixcfg/extras/helpers/cosmic-theme/generated/stylix-dark.ron".text = generateDarkTheme;
      "dev/nix/nixcfg/extras/helpers/cosmic-theme/generated/stylix-light.ron".text = generateLightTheme;
    };
  };
}
