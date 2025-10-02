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

  # Generate styled CSS with stylix colors and fonts
  styleCss = with config.lib.stylix.colors.withHashtag; ''
    window {
      border-radius: 8px;
      opacity: 0.95;
      border: 2px solid ${base0D};
      background-color: ${base00};
      padding: 12px;
    }

    label {
      font-family: '${config.stylix.fonts.monospace.name}';
      font-size: ${toString config.stylix.fonts.sizes.applications}pt;
      color: ${base05};
      font-weight: bold;
    }

    image {
      color: ${base0D};
    }

    progressbar {
      border-radius: 4px;
      background-color: ${base01};
      border: 1px solid ${base03};
    }

    progress {
      background-color: ${base0D};
      border-radius: 4px;
    }
  '';
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
        default = true;
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
      swayosd
    ];

    # Add user to video group for brightness control
    users.users."${user-settings.user.username}".extraGroups = [ "video" ];

    # Enable LibInput backend service if requested
    systemd.services.swayosd-libinput-backend = lib.mkIf cfg.swayosd.enableLibinputBackend {
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
        topMargin = cfg.swayosd.topMargin;
        stylePath = "${user-settings.user.home}/.config/swayosd/style.css";
      };
    };
  };
}
