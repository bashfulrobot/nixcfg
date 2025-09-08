{
  config,
  pkgs,
  lib,
  user-settings,
  ...
}:
let
  cfg = config.suites.kong;
in
{

  options = {
    suites.kong.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable kong specific tools.";
    };
  };

  config = lib.mkIf cfg.enable {
    cli = { };

    apps = {
      # crowdstrike.enable = true;
      kong-email.enable = true;
      kong-drive.enable = true;
      kong-calendar.enable = true;
      kongfluence.enable = true;
      sfdc.enable = true;
    };

    environment.systemPackages = with pkgs; [

    ];

    home-manager.users."${user-settings.user.username}" = {

    };
  };
}
