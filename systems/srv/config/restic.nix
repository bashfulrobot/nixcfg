{ user-settings, config, pkgs, secrets, ... }:
let
  restic-nfs-backup = ''
    #!/run/current-system/sw/bin/env fish

    set -x RESTIC_BIN "/run/current-system/sw/bin/restic"

    set -x RESTIC_HOST (hostname)
    set -x RESTIC_REPOSITORY "${secrets.restic.srv.restic_repository}"
    set -x AWS_ACCESS_KEY_ID "${secrets.restic.srv.b2_account_id}"
    set -x AWS_SECRET_ACCESS_KEY "${secrets.restic.srv.b2_account_key}"
    set -x AWS_DEFAULT_REGION "${secrets.restic.srv.region}"
    set -x RESTIC_PASSWORD "${secrets.restic.srv.restic_password}"

    function init_repo
      $RESTIC_BIN -r $RESTIC_REPOSITORY init
    end

    function restore_backup
      $RESTIC_BIN -r $RESTIC_REPOSITORY restore latest --target /srv/nfs/restores
    end

    function run_backup
      $RESTIC_BIN -r $RESTIC_REPOSITORY backup /srv/nfs
      $RESTIC_BIN -r $RESTIC_REPOSITORY forget --prune --keep-daily 7 --keep-weekly 4 --keep-monthly 12 --keep-yearly 2
    end

    if test (count $argv) -gt 0 -a "$argv[1]" = "-init"
      init_repo
    else if test (count $argv) -gt 0 -a "$argv[1]" = "-restore"
      restore_backup
    else
      run_backup
    end
  '';
in {

  environment.systemPackages = with pkgs; [
    restic
    (writeScriptBin "restic-nfs-backup.sh" restic-nfs-backup)
  ];

  systemd.timers.restic-nfs-backup = {
    description = "Restic-nfs-backup timer";
    enable = true;
    wantedBy = [ "timers.target" ];
    partOf = [ "restic-nfs-backup.service" ];
    timerConfig = {
      Persistent = "true";
      OnCalendar = "*-*-* 03:00:00";
    };
  };

  systemd.services.restic-nfs-backup = {
    description = "Backup NFS with restic";
    enable = true;
    serviceConfig = {
      Type = "simple";
      ExecStart =
        "/run/current-system/sw/bin/fish /run/current-system/sw/bin/restic-nfs-backup.sh";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # home-manager.users."${user-settings.user.username}" = {
  # };
}
