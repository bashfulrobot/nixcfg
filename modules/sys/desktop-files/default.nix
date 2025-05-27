{
  user-settings,
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.sys.desktop-files;

in
{
  options = {
    sys.desktop-files = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable desktop-files";
      };
      reboot-firmware = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable reboot-firmware.desktop";
      };
      _1password = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable 1password.desktop";
      };
      suspend = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable suspend.desktop";
      };
      solaar = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable solaar.desktop";
      };
      shutdown = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable shutdown.desktop";
      };
      reboot-tailscale = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable reboot-tailscale.desktop";
      };
      reboot = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable reboot.desktop";
      };
      reboot-windows = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable reboot-windows.desktop";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${user-settings.user.username}" = {
      home.file = {
        "reboot-firmware.desktop" = lib.mkIf cfg.reboot-firmware {
          source = ./src/reboot-firmware.desktop;
          target = ".local/share/applications/reboot-firmware.desktop";
        };
        "1password.desktop" = lib.mkIf cfg._1password {
          source = ./src/1password.desktop;
          target = ".local/share/applications/1password.desktop";
        };
        "suspend.desktop" = lib.mkIf cfg.suspend {
          source = ./src/suspend.desktop;
          target = ".local/share/applications/suspend.desktop";
        };
        "solaar.desktop" = lib.mkIf cfg.solaar {
          source = ./src/solaar.desktop;
          target = ".local/share/applications/solaar.desktop";
        };
        "shutdown.desktop" = lib.mkIf cfg.shutdown {
          source = ./src/shutdown.desktop;
          target = ".local/share/applications/shutdown.desktop";
        };
        "reboot-tailscale.desktop" = lib.mkIf cfg.reboot-tailscale {
          source = ./src/reboot-tailscale.desktop;
          target = ".local/share/applications/reboot-tailscale.desktop";
        };
        "reboot.desktop" = lib.mkIf cfg.reboot {
          source = ./src/reboot.desktop;
          target = ".local/share/applications/reboot.desktop";
        };
        "reboot-windows.desktop" = lib.mkIf cfg.reboot-windows {
          source = ./src/reboot-windows.desktop;
          target = ".local/share/applications/reboot-windows.desktop";
        };
      };
    };
  };
}
