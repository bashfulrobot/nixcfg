{
  user-settings,
  config,
  lib,
  ...
}:
let
  wallpaperPath = config.sys.wallpapers.getWallpaper "professional";
  inherit (config.lib.stylix) colors;

  # Helper function to convert hex color to decimal rgba
  hexToRgba = color: let
    # Remove # prefix if present
    cleanColor = lib.removePrefix "#" color;
    # Helper to convert a two-digit hex string to decimal
    hexPairToInt = hexPair:
      let
        first = builtins.substring 0 1 hexPair;
        second = builtins.substring 1 1 hexPair;
        charToInt = c:
          if c == "a" || c == "A" then 10
          else if c == "b" || c == "B" then 11
          else if c == "c" || c == "C" then 12
          else if c == "d" || c == "D" then 13
          else if c == "e" || c == "E" then 14
          else if c == "f" || c == "F" then 15
          else lib.toInt c;
      in
        (charToInt first) * 16 + (charToInt second);
    # Convert hex to rgb components
    r = hexPairToInt (builtins.substring 0 2 cleanColor);
    g = hexPairToInt (builtins.substring 2 2 cleanColor);
    b = hexPairToInt (builtins.substring 4 2 cleanColor);
  in {
    red = r / 255.0;
    green = g / 255.0;
    blue = b / 255.0;
    alpha = 1.0;
  };

  # Helper function to generate rgba RON format
  formatRgba = rgba: ''
    (
        red: ${toString rgba.red},
        green: ${toString rgba.green},
        blue: ${toString rgba.blue},
        alpha: ${toString rgba.alpha},
    )'';

  # Helper function to format rgb without alpha
  formatRgb = rgba: ''
    (
        red: ${toString rgba.red},
        green: ${toString rgba.green},
        blue: ${toString rgba.blue},
    )'';

  # Generate dark theme based on stylix colors
  generateDarkTheme = let
    # Base color mappings from stylix base16 to cosmic palette
    base00 = hexToRgba colors.base00; # neutral_0 (darkest)
    base01 = hexToRgba colors.base01; # neutral_1
    base02 = hexToRgba colors.base02; # neutral_2
    base03 = hexToRgba colors.base03; # neutral_3
    base04 = hexToRgba colors.base04; # neutral_4
    base05 = hexToRgba colors.base05; # neutral_5 (main text)
    base06 = hexToRgba colors.base06; # neutral_6
    base07 = hexToRgba colors.base07; # neutral_10 (lightest)

    # Accent colors
    red = hexToRgba colors.base08;
    orange = hexToRgba colors.base09;
    yellow = hexToRgba colors.base0A;
    green = hexToRgba colors.base0B;
    cyan = hexToRgba colors.base0C;
    blue = hexToRgba colors.base0D;
    purple = hexToRgba colors.base0E;
    brown = hexToRgba colors.base0F;
  in ''
(
    palette: Dark((
        name: "stylix-dark",
        bright_red: ${formatRgba red},
        bright_green: ${formatRgba green},
        bright_orange: ${formatRgba orange},
        gray_1: ${formatRgba base01},
        gray_2: ${formatRgba base02},
        neutral_0: ${formatRgba base00},
        neutral_1: ${formatRgba base01},
        neutral_2: ${formatRgba base02},
        neutral_3: ${formatRgba base03},
        neutral_4: ${formatRgba base04},
        neutral_5: ${formatRgba base05},
        neutral_6: ${formatRgba base06},
        neutral_7: ${formatRgba base06},
        neutral_8: ${formatRgba base06},
        neutral_9: ${formatRgba base07},
        neutral_10: ${formatRgba base07},
        accent_blue: ${formatRgba blue},
        accent_indigo: ${formatRgba blue},
        accent_purple: ${formatRgba purple},
        accent_pink: ${formatRgba purple},
        accent_red: ${formatRgba red},
        accent_orange: ${formatRgba orange},
        accent_yellow: ${formatRgba yellow},
        accent_green: ${formatRgba green},
        accent_warm_grey: ${formatRgba base04},
        ext_warm_grey: ${formatRgba base04},
        ext_orange: ${formatRgba orange},
        ext_yellow: ${formatRgba yellow},
        ext_blue: ${formatRgba cyan},
        ext_purple: ${formatRgba purple},
        ext_pink: ${formatRgba purple},
        ext_indigo: ${formatRgba blue},
    )),
    spacing: (
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
    ),
    corner_radii: (
        radius_0: (0.0, 0.0, 0.0, 0.0),
        radius_xs: (4.0, 4.0, 4.0, 4.0),
        radius_s: (8.0, 8.0, 8.0, 8.0),
        radius_m: (16.0, 16.0, 16.0, 16.0),
        radius_l: (32.0, 32.0, 32.0, 32.0),
        radius_xl: (160.0, 160.0, 160.0, 160.0),
    ),
    neutral_tint: Some(${formatRgb base05}),
    bg_color: Some(${formatRgba base00}),
    primary_container_bg: None,
    secondary_container_bg: None,
    text_tint: Some(${formatRgb base05}),
    accent: Some(${formatRgb blue}),
    success: Some(${formatRgb green}),
    warning: Some(${formatRgb yellow}),
    destructive: Some(${formatRgb red}),
    is_frosted: false,
    gaps: (0, 15),
    active_hint: 1,
    window_hint: None,
)
  '';

  # Generate light theme using white background with Stylix accent colors
  generateLightTheme = let
    # White background color scheme with proper contrast
    white = { red = 1.0; green = 1.0; blue = 1.0; alpha = 1.0; };
    lightGray1 = { red = 0.8862745; green = 0.8862745; blue = 0.8862745; alpha = 1.0; };
    lightGray2 = { red = 0.7764706; green = 0.7764706; blue = 0.7764706; alpha = 1.0; };
    lightGray3 = { red = 0.67058825; green = 0.67058825; blue = 0.67058825; alpha = 1.0; };
    lightGray4 = { red = 0.5686275; green = 0.5686275; blue = 0.5686275; alpha = 1.0; };
    mediumGray = { red = 0.46666667; green = 0.46666667; blue = 0.46666667; alpha = 1.0; };
    darkGray6 = { red = 0.36862746; green = 0.36862746; blue = 0.36862746; alpha = 1.0; };
    darkGray7 = { red = 0.2784314; green = 0.2784314; blue = 0.2784314; alpha = 1.0; };
    darkGray8 = { red = 0.1882353; green = 0.1882353; blue = 0.1882353; alpha = 1.0; };
    darkGray9 = { red = 0.105882354; green = 0.105882354; blue = 0.105882354; alpha = 1.0; };
    black = { red = 0.0; green = 0.0; blue = 0.0; alpha = 1.0; };

    # Bright Stylix accent colors for light theme
    red = hexToRgba colors.base08;
    orange = hexToRgba colors.base09;
    yellow = hexToRgba colors.base0A;
    green = hexToRgba colors.base0B;
    cyan = hexToRgba colors.base0C;
    blue = hexToRgba colors.base0D;
    purple = hexToRgba colors.base0E;
    brown = hexToRgba colors.base0F;

    # Background uses white, text uses dark
    lightBg = white;
    darkText = black;
  in ''
(
    palette: Light((
        name: "stylix-light",
        bright_red: ${formatRgba red},
        bright_green: ${formatRgba green},
        bright_orange: ${formatRgba orange},
        gray_1: ${formatRgba lightGray1},
        gray_2: ${formatRgba lightGray2},
        neutral_0: ${formatRgba white},
        neutral_1: ${formatRgba lightGray1},
        neutral_2: ${formatRgba lightGray2},
        neutral_3: ${formatRgba lightGray3},
        neutral_4: ${formatRgba lightGray4},
        neutral_5: ${formatRgba mediumGray},
        neutral_6: ${formatRgba darkGray6},
        neutral_7: ${formatRgba darkGray7},
        neutral_8: ${formatRgba darkGray8},
        neutral_9: ${formatRgba darkGray9},
        neutral_10: ${formatRgba black},
        accent_blue: ${formatRgba blue},
        accent_indigo: ${formatRgba blue},
        accent_purple: ${formatRgba purple},
        accent_pink: ${formatRgba purple},
        accent_red: ${formatRgba red},
        accent_orange: ${formatRgba orange},
        accent_yellow: ${formatRgba yellow},
        accent_green: ${formatRgba green},
        accent_warm_grey: ${formatRgba lightGray4},
        ext_warm_grey: ${formatRgba lightGray4},
        ext_orange: ${formatRgba orange},
        ext_yellow: ${formatRgba yellow},
        ext_blue: ${formatRgba cyan},
        ext_purple: ${formatRgba purple},
        ext_pink: ${formatRgba purple},
        ext_indigo: ${formatRgba blue},
    )),
    spacing: (
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
    ),
    corner_radii: (
        radius_0: (0.0, 0.0, 0.0, 0.0),
        radius_xs: (4.0, 4.0, 4.0, 4.0),
        radius_s: (8.0, 8.0, 8.0, 8.0),
        radius_m: (16.0, 16.0, 16.0, 16.0),
        radius_l: (32.0, 32.0, 32.0, 32.0),
        radius_xl: (160.0, 160.0, 160.0, 160.0),
    ),
    neutral_tint: Some(${formatRgb mediumGray}),
    bg_color: Some(${formatRgba white}),
    primary_container_bg: None,
    secondary_container_bg: None,
    text_tint: Some(${formatRgb black}),
    accent: Some(${formatRgb blue}),
    success: Some(${formatRgb green}),
    warning: Some(${formatRgb yellow}),
    destructive: Some(${formatRgb red}),
    is_frosted: false,
    gaps: (0, 15),
    active_hint: 1,
    window_hint: None,
)
  '';

in
{
  # COSMIC Appearance and Theme Configuration
  home-manager.users."${user-settings.user.username}" = {
    xdg.configFile = {
      # Wallpaper configuration for COSMIC Settings
      "cosmic/com.system76.CosmicSettings.Wallpaper/v1/custom-images".text = wallpaperPath;



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