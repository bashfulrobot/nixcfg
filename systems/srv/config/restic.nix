{ config, pkgs, secrets, ... }:
let
  resticEnvContent = ''
    RESTIC_REPOSITORY="${secrets.restic.srv.RESTIC_REPOSITORY}"
    RESTIC_PASSWORD="${secrets.restic.srv.RESTIC_PASSWORD}"
    B2_ACCOUNT_ID="${secrets.restic.srv.B2_ACCOUNT_ID}"
    B2_ACCOUNT_KEY="${secrets.restic.srv.B2_ACCOUNT_KEY}"
  '';
in {
  # Create the file in /etc
  environment.etc."restic/env-srv-restic" = {
    text = resticEnvContent;
    mode = "0600"; # Set the file permissions to be readable only by root
  };

  # Configure restic to use the env file
  services.restic.backups = {
    b2backup = {
      initialize = true;
      paths = [ "/srv/nfs" ];
      environmentFile = "/etc/restic/env-srv-restic";
      pruneOpts = [ "--keep-daily 7" "--keep-weekly 4" "--keep-monthly 6" ];
      extraBackupArgs = [
        "--exclude=/srv/nfs/spitfire/jellyfin"
      ];
      timerConfig = {
        OnCalendar = "03:00:00";
        RandomizedDelaySec = "5m";
        Persistent = true;
      };
    };
  };
}
