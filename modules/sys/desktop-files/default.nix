{ user-settings, pkgs, config, lib, inputs, ... }:
let cfg = config.sys.desktop-files;

in {
  options = {
    sys.desktop-files.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable desktop-files";
    };
    sys.desktop-files.reboot-firmware = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable reboot-firmware.desktop";
    };
    sys.desktop-files._1password = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable 1password.desktop";
    };
    sys.desktop-files.suspend = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable suspend.desktop";
    };
    sys.desktop-files.solaar = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable solaar.desktop";
    };
    sys.desktop-files.shutdown = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable shutdown.desktop";
    };
    sys.desktop-files.reboot-tailscale = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable reboot-tailscale.desktop";
    };
    sys.desktop-files.reboot = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable reboot.desktop";
    };
    sys.desktop-files.reboot-windows = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable reboot-windows.desktop";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${user-settings.user.username}" = {
      home.file."reboot-firmware.desktop" = lib.mkIf cfg.reboot-firmware {
        source = ./src/reboot-firmware.desktop;
        target = ".local/share/applications/reboot-firmware.desktop";
      };
      home.file."1password.desktop" = lib.mkIf cfg._1password {
        source = ./src/1password.desktop;
        target = ".local/share/applications/1password.desktop";
      };
      home.file."suspend.desktop" = lib.mkIf cfg.suspend {
        source = ./src/suspend.desktop;
        target = ".local/share/applications/suspend.desktop";
      };
      home.file."solaar.desktop" = lib.mkIf cfg.solaar {
        source = ./src/solaar.desktop;
        target = ".local/share/applications/solaar.desktop";
      };
      home.file."shutdown.desktop" = lib.mkIf cfg.shutdown {
        source = ./src/shutdown.desktop;
        target = ".local/share/applications/shutdown.desktop";
      };
      home.file."reboot-tailscale.desktop" = lib.mkIf cfg.reboot-tailscale {
        source = ./src/reboot-tailscale.desktop;
        target = ".local/share/applications/reboot-tailscale.desktop";
      };
      home.file."reboot.desktop" = lib.mkIf cfg.reboot {
        source = ./src/reboot.desktop;
        target = ".local/share/applications/reboot.desktop";
      };
      home.file."reboot-windows.desktop" = lib.mkIf cfg.reboot-windows {
        source = ./src/reboot-windows.desktop;
        target = ".local/share/applications/reboot-windows.desktop";
      };
    };
  };
}
