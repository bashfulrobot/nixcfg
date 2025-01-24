{ user-settings, config, pkgs, secrets, ... }: {
  services.restic.backups = {
    b2backup = {
      environmentFile = "/home/${user-settings.user.username}/.config/restic/srv-nfs-env";
      initialize = true;
      paths = [ "/srv/nfs" ];
      repository = "${secrets.restic.srv.RESTIC_REPOSITORY}";
      pruneOpts = [ "--keep-daily 7" "--keep-weekly 4" "--keep-monthly 6" ];
      extraBackupArgs = [ "--exclude=/srv/nfs/spitfire/jellyfin" ];
      timerConfig = {
        OnCalendar = "03:00:00";
        RandomizedDelaySec = "5m";
        Persistent = true;
      };
    };
  };

  home-manager.users."${user-settings.user.username}" = {
    home.file.".config/restic/srv-nfs-env" = {
      text = ''
        RESTIC_PASSWORD=${secrets.restic.srv.RESTIC_PASSWORD}
        B2_ACCOUNT_ID=${secrets.restic.srv.B2_ACCOUNT_ID}
        B2_ACCOUNT_KEY=${secrets.restic.srv.B2_ACCOUNT_KEY}
      '';
    };

  };
}
