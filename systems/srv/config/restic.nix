{ user-settings, config, pkgs, secrets, ... }:
let
  restic-nfs-backup = ''
    #!/run/current-system/sw/bin/env fish

    set -x RESTIC_HOST (hostname)
    set -x RESTIC_REPOSITORY "${secrets.restic.srv.restic_repository}"
    set -x AWS_SECRET_ACCESS_KEY "${secrets.restic.srv.b2_account_id}"
    set -x AWS_DEFAULT_REGION "${secrets.restic.srv.region}"
    set -x B2_ACCOUNT_KEY "${secrets.restic.srv.b2_account_key}"
    set -x RESTIC_PASSWORD "${secrets.restic.srv.restic_password}"

    # Debugging output
    echo "RESTIC_REPOSITORY: $RESTIC_REPOSITORY"
    echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY"
    echo "B2_ACCOUNT_KEY: $B2_ACCOUNT_KEY"
    echo "RESTIC_PASSWORD: $RESTIC_PASSWORD"

    function init_repo
      restic -r $RESTIC_REPOSITORY init
    end

    function run_backup
      restic -r $RESTIC_REPOSITORY backup /srv/nfs
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

  # systemd.services.autorestic = {
  #   description = "Autorestic Backup Service";
  #   serviceConfig = {
  #     ExecStart =
  #       "autorestic -c /home/${user-settings.user.username}/.autorestic.yaml --ci cron";
  #     User = "root";
  #   };
  # };

  # systemd.timers.autorestic = {
  #   description = "Autorestic Backup Timer";
  #   wantedBy = [ "timers.target" ];
  #   timerConfig = {
  #     OnCalendar = "*:0/5";
  #     Persistent = true;
  #   };
  # };

  # home-manager.users."${user-settings.user.username}" = {
  # };
}
