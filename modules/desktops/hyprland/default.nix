{ config, pkgs, lib, user-settings, ... }:
let cfg = config.desktop.hyprland;
in {

  options = {
    desktop.hyprland.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Hyprland..";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [

    ];

    home-manager.users."${user-settings.user.username}" = {

    };
  };
}
