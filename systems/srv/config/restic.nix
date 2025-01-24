{ user-settings, config, pkgs, secrets, ... }: {

  environment.systemPackages = with pkgs; [ restic autorestic ];

  services.cron = {
    enable = true;
    systemCronJobs = [
      {
        name = "autorestic";
        schedule = "*/5 * * * *";
        job = "autorestic -c /home/${user-settings.user.username}/.autorestic.yaml --ci cron";
        user = "root";
      }
    ];
  };

  home-manager.users."${user-settings.user.username}" = {

    home.file.".autorestic.yaml" = {
      text = ''
        version: 2

        global:
          forget:
            keep-last: 5 # always keep at least 5 snapshots
            keep-hourly: 3 # keep 3 last hourly snapshots
            keep-daily: 4 # keep 4 last daily snapshots
            keep-weekly: 1 # keep 1 last weekly snapshots
            keep-monthly: 12 # keep 12 last monthly snapshots
            keep-yearly: 2 # keep 7 last yearly snapshots
            keep-within: '7d' # keep snapshots from the last 14 days

        locations:
          nfs:
            from:
              - /srv/nfs
            to: b2-nfs
            cron: '0 3 * * *' # Every Day at 3:00 AM
            forget: prune
            options:
              exclude:
                - /srv/nfs/lost+found
                - /srv/nfs/spitfire/jellyfin

        backends:
          b2-nfs:
            type: b2
            path: 'srv-nfs'
            env:
              B2_ACCOUNT_ID: "${secrets.restic.B2_ACCOUNT_ID}"
              B2_ACCOUNT_KEY: "${secrets.restic.B2_ACCOUNT_KEY}"
      '';
    };

  };
}
