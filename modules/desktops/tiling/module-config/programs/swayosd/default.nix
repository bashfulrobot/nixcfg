{
  user-settings,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.desktops.tiling.hyprland;

  # Generate SwayOSD config.toml content
  configToml = ''
    [server]
    show_percentage = ${if cfg.swayosd.showPercentage then "true" else "false"}
    max_volume = ${toString cfg.swayosd.maxVolume}
  '';

  # Use stylix-theme library for CSS generation
  buildTheme = pkgs.callPackage ../../../../../../lib/stylix-theme.nix { };
  styleCss = buildTheme.build {
    inherit (config.lib.stylix) colors;
    inherit (config.stylix) fonts;
    file = builtins.replaceStrings
      [ "@fontSize" ]
      [ "${toString config.stylix.fonts.sizes.applications}pt" ]
      (builtins.readFile ./style.css);
  };
in
{
  options = {
    desktops.tiling.hyprland.swayosd = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable swayosd On-Screen Display for Hyprland";
      };

      showPercentage = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show percentage values in OSD";
      };

      maxVolume = lib.mkOption {
        type = lib.types.int;
        default = 100;
        description = "Maximum volume level (100 = 100%)";
      };

      topMargin = lib.mkOption {
        type = lib.types.float;
        default = 0.9;
        description = "OSD position from top of screen (0.0 = top, 1.0 = bottom)";
      };

      enableLibinputBackend = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable SwayOSD LibInput backend for automatic key detection (caps lock, num lock, scroll lock)";
      };

      enableScreenshotNotifications = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable OSD notifications for screenshot actions";
      };
    };
  };

  config = lib.mkIf (cfg.enable && cfg.swayosd.enable) {
    # Ensure swayosd package is available
    environment.systemPackages = with pkgs; [

      # keep-sorted start case=no numeric=yes
      swayosd
      # keep-sorted end
    ];

    # Add user to video and input groups for brightness control and caps lock detection
    users.users."${user-settings.user.username}".extraGroups = [ "video" "input" ];

    # Enable LibInput backend service if requested as user service
    systemd.user.services.swayosd-libinput-backend = lib.mkIf cfg.swayosd.enableLibinputBackend {
      description = "SwayOSD LibInput Backend";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.swayosd}/bin/swayosd-libinput-backend";
        Restart = "always";
        RestartSec = 3;
      };
    };

    home-manager.users."${user-settings.user.username}" = {
      # Generate config files using XDG
      xdg.configFile = {
        "swayosd/config.toml".text = configToml;
        "swayosd/style.css".text = styleCss;
      };

      # Configure SwayOSD service using home-manager options
      services.swayosd = {
        enable = true;
        package = pkgs.swayosd;
        inherit (cfg.swayosd) topMargin;
        stylePath = "${user-settings.user.home}/.config/swayosd/style.css";
      };
    };
  };
}
