{ user-settings, pkgs, config, lib, inputs, ... }:
let cfg = config.desktops.cosmic;
in {
  options = {
    desktops.cosmic.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable COSMIC Desktop Environment";
    };
  };

  config = lib.mkIf cfg.enable {

    # Enable stylix theming support
    sys.stylix-theme.enable = true;

    # Enable COSMIC Desktop Environment (NixOS 25.05+ native support)
    services = {
      desktopManager.cosmic.enable = true;
      displayManager.cosmic-greeter.enable = true;
      desktopManager.cosmic.xwayland.enable = true;
    };

  };
}