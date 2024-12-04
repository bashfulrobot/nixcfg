{ user-settings, pkgs, config, lib, ... }:
let cfg = config.sys.power;
in {

  options = {
    sys.power.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable laptop power tools.";
    };
  };

  config = lib.mkIf cfg.enable {
    # environment.systemPackages = with pkgs; [  ];
    # powerManagement.enable = true;

    services.tlp.enable = true;

    # home-manager.users."${user-settings.user.username}" = {

    # };
  };
}
