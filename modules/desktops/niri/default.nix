{ user-settings, pkgs, secrets, config, lib, ... }:
let cfg = config.desktops.niri;
in {
  options = {
    desktops.niri.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Niri Desktop.";
    };
  };

  config = lib.mkIf cfg.enable {
    # environment.systemPackages = with pkgs; [  ];

    home-manager.users."${user-settings.user.username}" = {

    };
  };
}
