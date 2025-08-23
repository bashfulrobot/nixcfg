{ user-settings, pkgs, config, lib, ... }:
let 
  cfg = config.cli.flameshot;

  # Package selection based on support options
  # When x11Support is enabled, waylandSupport is automatically disabled
  actualWaylandSupport = cfg.waylandSupport && !cfg.x11Support;
  
  flameShotPkg = if actualWaylandSupport then
    pkgs.unstable.flameshot.override { enableWlrSupport = true; }
  else
    pkgs.unstable.flameshot;

in {
  options = {
    cli.flameshot.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable flameshot screenshot tool.";
    };

    cli.flameshot.x11Support = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable X11 support for flameshot (disables wayland support).";
    };

    cli.flameshot.waylandSupport = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Wayland support for flameshot (disabled when x11Support is true).";
    };
  };

  config = lib.mkIf cfg.enable {
    # No assertion needed - x11Support automatically disables wayland support

    environment.systemPackages = [ flameShotPkg ];

    home-manager.users."${user-settings.user.username}" = lib.mkMerge [
      # Base configuration
      {
        home.packages = [ flameShotPkg ];
      }

      # X11-specific configuration
      (lib.mkIf cfg.x11Support {
        home.sessionVariables = {
          QT_QPA_PLATFORM = "xcb";
        };
      })

      # Wayland-specific configuration (default)
      (lib.mkIf actualWaylandSupport {
        # Wayland support is handled by the package override
        # No additional configuration needed
      })
    ];
  };
}