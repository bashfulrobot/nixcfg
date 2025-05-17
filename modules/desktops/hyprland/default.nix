{ config, pkgs, lib, user-settings, ... }:
let cfg = config.desktops.hyprland;
in {

  options = {
    desktops.hyprland.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Hyprland using configurations from hyprflake.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Your hyprflake modules are already loaded at the system level via commonModules
    # and at the home-manager level via sharedModules in your flake.nix

    # You can add any additional local customizations here if needed
    environment.systemPackages = with pkgs;
      [
        # Additional packages
      ];
  };
}
