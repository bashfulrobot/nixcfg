{ user-settings, pkgs, config, lib, ... }:
let cfg = config.sys.power;
in {

  options = {
    sys.power.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable laptop power tools.";
    };
    
    sys.power.clamshell = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable clamshell mode - disable suspend on lid close.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      environment.systemPackages = with pkgs; [

        # keep-sorted start case=no numeric=yes
        brightnessctl
        light
        # keep-sorted end
      ];

      services.power-profiles-daemon.enable = true;

      # home-manager.users."${user-settings.user.username}" = {

      # };
    })
    
    (lib.mkIf cfg.clamshell {
      # Prevent the laptop from going to sleep when the lid closes
      # Only works if user is logged in
      services.logind.lidSwitchExternalPower = "ignore";

      # Disable all suspend modes
      systemd.sleep.extraConfig = ''
        AllowSuspend=no
        AllowHibernation=no
        AllowHybridSleep=no
        AllowSuspendThenHibernate=no
      '';
    })
  ];
}
