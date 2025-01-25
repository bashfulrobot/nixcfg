{ user-settings, config, pkgs, secrets, ... }:
let
  backup-mgr = ''
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

    function list_backups
      $RESTIC_BIN -r $RESTIC_REPOSITORY snapshots
    end

    function run_backup
      $RESTIC_BIN -r $RESTIC_REPOSITORY backup /srv/nfs
      $RESTIC_BIN -r $RESTIC_REPOSITORY forget --prune --keep-daily 7 --keep-weekly 4 --keep-monthly 12 --keep-yearly 2
    end

    function check_status
      systemctl status backup-mgr.timer
      systemctl status backup-mgr.service
    end

    function check_service_logs
      journalctl -u backup-mgr.service
    end

    function check_timer_logs
      journalctl -u backup-mgr.timer
    end

    function show_help
      echo "Usage: $argv[1] [OPTION]"
      echo "Options:"
      echo "  -help           Show this help message"
      echo "  -init           Initialize the repository"
      echo "  -list-backups   List all backups"
      echo "  -service-logs   Check the logs of the backup service"
      echo "  -restore        Restore the latest backup"
      echo "  -status         Check the status of the systemd timer and service"
      echo "  -timer-logs     Check the logs of the systemd timer"
    end

    if test (count $argv) -gt 0 -a "$argv[1]" = "-init"
      init_repo
    else if test (count $argv) -gt 0 -a "$argv[1]" = "-restore"
      restore_backup
    else if test (count $argv) -gt 0 -a "$argv[1]" = "-list-backups"
      list_backups
    else if test (count $argv) -gt 0 -a "$argv[1]" = "-status"
      check_status
    else if test (count $argv) -gt 0 -a "$argv[1]" = "-logs"
      check_logs
    else if test (count $argv) -gt 0 -a "$argv[1]" = "-timer-logs"
      check_timer_logs
    else if test (count $argv) -gt 0 -a "$argv[1]" = "-service-logs"
      check_service_logs
    else if test (count $argv) -gt 0 -a "$argv[1]" = "-help"
      show_help
    else
      run_backup
    end
  '';
in {

  environment.systemPackages = with pkgs; [
    restic
    (writeScriptBin "backup-mgr" backup-mgr)
  ];

  systemd.timers.backup-mgr = {
    description = "backup-mgr timer";
    enable = true;
    wantedBy = [ "timers.target" ];
    partOf = [ "backup-mgr.service" ];
    timerConfig = {
      Persistent = "true";
      OnCalendar = "*-*-* 03:00:00";
    };
  };

  systemd.services.backup-mgr = {
    description = "Backup NFS with restic";
    enable = true;
    serviceConfig = {
      Type = "simple";
      ExecStart =
        "/run/current-system/sw/bin/fish /run/current-system/sw/bin/backup-mgr";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # home-manager.users."${user-settings.user.username}" = {
  # };
}
