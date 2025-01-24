{ user-settings, config, pkgs, secrets, ... }:
let
  restic-nfs-backup = ''
    #!/run/current-system/sw/bin/env fish

    set -x RESTIC_HOST (hostname)
    set -x RESTIC_REPOSITORY "${secrets.restic.srv.restic_repository}"
    set -x AWS_ACCESS_KEY_ID "${secrets.restic.srv.b2_account_id}"
    set -x AWS_SECRET_ACCESS_KEY "${secrets.restic.srv.b2_account_key}"
    set -x AWS_DEFAULT_REGION "${secrets.restic.srv.region}"
    set -x RESTIC_PASSWORD "${secrets.restic.srv.restic_password}"

    function init_repo
      restic -r $RESTIC_REPOSITORY init
    end

    function run_backup
      restic -r $RESTIC_REPOSITORY backup /srv/nfs
      restic -r $RESTIC_REPOSITORY forget --prune --keep-daily 7 --keep-weekly 4 --keep-monthly 12 --keep-yearly 2
    end

    if test (count $argv) -gt 0 -a "$argv[1]" = "-init"
      init_repo
    else
      run_backup
    end
  '';
in {

  environment.systemPackages = with pkgs; [
    restic
    (writeScriptBin "restic-nfs-backup.sh" restic-nfs-backup)
  ];

systemd.services.restic-nfs-backup = {
    description = "Restic NFS Backup Service";
    serviceConfig = {
      ExecStart = "${pkgs.fish}/bin/fish /run/current-system/sw/bin/restic-nfs-backup.sh";
      User = "root";
    };
  };

  systemd.timers.restic-nfs-backup = {
    description = "Restic NFS Backup Timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      Persistent = true;
      OnCalendar = "03:00";
    };
  };

  # home-manager.users."${user-settings.user.username}" = {
  # };
}
