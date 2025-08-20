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
      description = "Enable Kong tooling..";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      google-cloud-sdk # Google Cloud SDK
      insomnia # API client - TODO: needs an update. Learn how to version bump
    ];

    services.flatpak.packages = [

    ];
    home-manager.users."${user-settings.user.username}" = {
      programs = {
        k9s = {
          enable = true;
        };
      };
    };
  };
}
