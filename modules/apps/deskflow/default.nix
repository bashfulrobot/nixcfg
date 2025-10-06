{
  user-settings,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.apps.deskflow;
in
{
  options = {
    apps.deskflow.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Deskflow Software KVM.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [

      # keep-sorted start case=no numeric=yes
      unstable.deskflow
      # keep-sorted end
    ];

    # Set up signature and initial icons
    home-manager.users."${user-settings.user.username}" = {

    };
  };
}