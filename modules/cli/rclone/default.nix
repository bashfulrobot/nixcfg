{
  user-settings,
  pkgs,
  secrets,
  config,
  lib,
  ...
}:
let
  cfg = config.cli.rclone;

in
{
  options = {
    cli.rclone.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable rclone cloud storage synchronization tool.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      rclone
    ];

    home-manager.users."${user-settings.user.username}" = {
      programs.rclone = {
        enable = true;
        remotes = {
          gdrive = {
            config = {
              type = "drive";
              scope = "drive";
              client_id = secrets.rclone.google_drive.client_id;
              client_secret = secrets.rclone.google_drive.client_secret;
            };
          };
        };
      };
    };
  };
}
